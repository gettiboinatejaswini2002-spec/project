

-- Flights table
CREATE TABLE Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    total_seats INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seats table (to manage seat availability)
CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    is_booked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id) ON DELETE CASCADE
);

-- Bookings table
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('CONFIRMED','CANCELLED') DEFAULT 'CONFIRMED',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id) ON DELETE CASCADE
);
-- Flights
INSERT INTO Flights (flight_number, origin, destination, departure_time, arrival_time, total_seats) VALUES
('AI101', 'New Delhi', 'Mumbai', '2025-11-12 06:00:00', '2025-11-12 08:30:00', 10),
('AI102', 'Mumbai', 'Bangalore', '2025-11-01 09:00:00', '2025-11-01 11:00:00', 10);

-- Customers
INSERT INTO Customers (first_name, last_name, email, phone) VALUES
('Rahul','Sharma','rahul@gmail.com','9876543210'),
('Anjali','Verma','anjali@gmail.com','9123456780');

-- Seats for Flight AI101
INSERT INTO Seats (flight_id, seat_number) VALUES
(1,'1A'),(1,'1B'),(1,'1C'),(1,'1D'),(1,'2A'),(1,'2B'),(1,'2C'),(1,'2D'),(1,'3A'),(1,'3B');

-- Seats for Flight AI102
INSERT INTO Seats (flight_id, seat_number) VALUES
(2,'1A'),(2,'1B'),(2,'1C'),(2,'1D'),(2,'2A'),(2,'2B'),(2,'2C'),(2,'2D'),(2,'3A'),(2,'3B');

-- Bookings
INSERT INTO Bookings (customer_id, flight_id, seat_id) VALUES
(1,1,1), -- Rahul booked seat 1A on AI101
(2,1,2); -- Anjali booked seat 1B on AI101
SELECT s.seat_number
FROM Seats s
LEFT JOIN Bookings b ON s.seat_id = b.seat_id AND b.status='CONFIRMED'
WHERE s.flight_id = 1 AND (b.seat_id IS NULL OR s.is_booked = FALSE);
SELECT * 
FROM Flights
WHERE origin='New Delhi' AND destination='Mumbai' AND DATE(departure_time)='2025-11-12';
SELECT c.first_name, c.last_name, f.flight_number, s.seat_number, b.status, b.booking_date
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Flights f ON b.flight_id = f.flight_id
JOIN Seats s ON b.seat_id = s.seat_id;

DELIMITER $$
CREATE TRIGGER after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats
    SET is_booked = TRUE
    WHERE seat_id = NEW.seat_id;
END$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.status='CANCELLED' THEN
        UPDATE Seats
        SET is_booked = FALSE
        WHERE seat_id = NEW.seat_id;
        END IF;
END$$
DELIMITER ;


CREATE OR REPLACE VIEW vw_flight_availability AS
SELECT f.flight_id, f.flight_number, f.origin, f.destination, f.departure_time, f.arrival_time,
       f.total_seats - COUNT(b.booking_id) AS available_seats
FROM Flights f
LEFT JOIN Bookings b ON f.flight_id = b.flight_id AND b.status='CONFIRMED'
GROUP BY f.flight_id, f.flight_number, f.origin, f.destination, f.departure_time, f.arrival_time;

SELECT c.first_name, c.last_name, f.flight_number, f.origin, f.destination, s.seat_number, b.status, b.booking_date
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Flights f ON b.flight_id = f.flight_id
JOIN Seats s ON b.seat_id = s.seat_id
ORDER BY b.booking_date DESC;
DELIMITER $$
CREATE PROCEDURE sp_book_seat(IN p_customer_id INT, IN p_flight_id INT, IN p_seat_number VARCHAR(5))
BEGIN
    DECLARE seat INT;
    SELECT seat_id INTO seat 
    FROM Seats 
    WHERE flight_id = p_flight_id AND seat_number = p_seat_number AND is_booked = FALSE
    LIMIT 1;
    
    IF seat IS NOT NULL THEN
        INSERT INTO Bookings (customer_id, flight_id, seat_id) VALUES (p_customer_id, p_flight_id, seat);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat not available!';
    END IF;
END$$
DELIMITER ;

-- Procedure to cancel a booking
DELIMITER $$
CREATE PROCEDURE sp_cancel_booking(IN p_booking_id INT)
BEGIN
    UPDATE Bookings
    SET status = 'CANCELLED'
    WHERE booking_id = p_booking_id AND status = 'CONFIRMED';
END$$
DELIMITER ;

SELECT * FROM vw_flight_availability;
-- View flight availability


-- View booking summary
SELECT * FROM vw_booking_summary;
