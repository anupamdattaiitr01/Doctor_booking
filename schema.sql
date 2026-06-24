-- Create custom enumerated types for strict status control
CREATE TYPE appointment_status AS ENUM ('scheduled', 'completed', 'canceled', 'no_show');

-- 1. Users Table (Patients)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Doctors Table (Bio Column Removed!)
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Doctor Availability Slots (The Concurrency Battleground)
CREATE TABLE availability_slots (
    slot_id SERIAL PRIMARY KEY,
    doctor_id INT REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_booked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite Unique Constraint: Prevents a doctor from having overlapping duplicate slots
    CONSTRAINT unique_doctor_slot UNIQUE (doctor_id, slot_date, start_time)
);

-- 4. Appointments Table
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES users(user_id) ON DELETE RESTRICT,
    doctor_id INT REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    slot_id INT REFERENCES availability_slots(slot_id) ON DELETE RESTRICT,
    status appointment_status DEFAULT 'scheduled',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Enforce that a slot can only ever be linked to ONE appointment row
    CONSTRAINT unique_slot_appointment UNIQUE (slot_id)
);