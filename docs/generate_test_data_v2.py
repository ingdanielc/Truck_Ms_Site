import random
import datetime
import os

# Configuration
OWNERS_COUNT = 12
OUTPUT_DIR = 'scripts/test_data_two'
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Hash for '12345678'
PASS_HASH = 'fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe'

def get_city_id():
    return random.randint(1, 82)

def generate_reference_data():
    content = ""
    content += "INSERT INTO document_type (id, name) VALUES (1, 'CC'), (2, 'CE'), (3, 'NIT');\n"
    content += "INSERT INTO gender (id, name) VALUES (1, 'Masculino'), (2, 'Femenino'), (3, 'Otro');\n"
    content += "INSERT INTO city (id, name, state) VALUES " + ", ".join([f"({i}, 'Ciudad {i}', 'Estado {i}')" for i in range(1, 101)]) + ";\n"
    content += "INSERT INTO salary_type (id, name) VALUES (1, 'Fijo'), (2, 'Variable');\n"
    content += "INSERT INTO vehicle_brand (id, name) VALUES (1, 'Kenworth'), (2, 'International'), (3, 'Freightliner'), (4, 'Foton');\n"
    content += "INSERT INTO expense_category (id, name, description) VALUES (1, 'Combustible', 'Gastos de gasolina'), (2, 'Peajes', 'Pagos de peaje'), (3, 'Mantenimiento', 'Reparaciones'), (4, 'Viáticos', 'Alimentación y hospedaje');\n"
    content += "INSERT INTO roles (id, name, description) VALUES (1, 'ADMIN', 'Administrador'), (2, 'OWNER', 'Propietario de vehículos'), (3, 'DRIVER', 'Conductor de vehículos');\n"
    return content

# 1. Reference Data
print("Generating 01_reference_data.sql...")
with open(f'{OUTPUT_DIR}/01_reference_data.sql', 'w', encoding='utf-8') as f:
    f.write(generate_reference_data())

# Data structures for relational integrity
users = []
owners = []
drivers = []
vehicles = []
vehicle_owners = []
user_roles = []

# ID Counters
driver_id_counter = 1
vehicle_id_counter = 1
trip_id_counter = 1
user_id_counter = 2 # Start from 2 to respect existing admin (UID 1)

print("Calculating Users, Owners, Drivers and Vehicles...")
# Generate Owners
for i in range(1, OWNERS_COUNT + 1):
    owner_uid = user_id_counter
    user_id_counter += 1
    
    name = f"Owner {i}"
    email = f"owner{i}@test.com"
    users.append(f"({owner_uid}, '{name}', '{email}', '{PASS_HASH}', 'Activo')")
    owners.append(f"({i}, 1, 'DOC-O-{i}', '{name}', '{email}', '3000000{i:03}', {get_city_id()}, {random.randint(1,2)}, '1980-01-01', {owner_uid}, 100, FALSE)")
    user_roles.append(f"({owner_uid}, 2)") # OWNER role
    
    # Formula: owner_id * 3
    count_per_owner = i * 3
    for j in range(1, count_per_owner + 1):
        did = driver_id_counter
        driver_id_counter += 1
        
        duid = user_id_counter
        user_id_counter += 1
        
        dname = f"Driver {did} (O{i})"
        demail = f"driver{did}@test.com"
        users.append(f"({duid}, '{dname}', '{demail}', '{PASS_HASH}', 'Activo')")
        drivers.append(f"({did}, 1, 'DOC-D-{did}', '{dname}', '{demail}', '3100000{did:03}', {get_city_id()}, {random.randint(1,2)}, '1990-01-01', {random.randint(1,2)}, 2000000, 'C3', 'LIC-{did}', '2030-01-01', {duid}, {i})")
        user_roles.append(f"({duid}, 3)") # DRIVER role
        
        vid = vehicle_id_counter
        vehicle_id_counter += 1
        plate = f"V{vid:04}-O{i}"
        status = 'Activo'
        vehicles.append(f"({vid}, '{plate}', {did}, {random.randint(1,4)}, 'Model-T', 2020, 'White', '{status}')")
        vehicle_owners.append(f"({vid}, {i}, 100.00, TRUE)")

# Helper to write files with streaming logic to avoid huge memory blobs
def write_large_sql(filename, table, columns, data_list, delete_where=None):
    print(f"Writing {filename}...")
    with open(filename, 'w', encoding='utf-8') as f:
        if delete_where:
            f.write(f"DELETE FROM {table} WHERE {delete_where};\n")
        else:
            f.write(f"DELETE FROM {table};\n")
        f.write(f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n")
        for idx, row in enumerate(data_list):
            is_last = (idx == len(data_list) - 1)
            f.write(f"{row}{';' if is_last else ','}\n")

write_large_sql(f'{OUTPUT_DIR}/02_users.sql', 'users', ['id', 'name', 'email', 'password', 'status'], users, delete_where="id > 1")
write_large_sql(f'{OUTPUT_DIR}/03_owners.sql', 'owner', ['id', 'document_type_id', 'document_number', 'name', 'email', 'cell_phone', 'city_id', 'gender_id', 'birthdate', 'user_id', 'max_vehicles', 'is_driver'], owners)
write_large_sql(f'{OUTPUT_DIR}/04_drivers.sql', 'driver', ['id', 'document_type_id', 'document_number', 'name', 'email', 'cell_phone', 'city_id', 'gender_id', 'birthdate', 'salary_type_id', 'salary', 'license_category', 'license_number', 'license_expiry', 'user_id', 'owner_id'], drivers)
write_large_sql(f'{OUTPUT_DIR}/05_vehicles.sql', 'vehicle', ['id', 'plate', 'current_driver_id', 'vehicle_brand_id', 'model', 'year', 'color', 'status'], vehicles)
write_large_sql(f'{OUTPUT_DIR}/06_vehicle_owner.sql', 'vehicle_owner', ['vehicle_id', 'owner_id', 'ownership_percentage', 'is_active'], vehicle_owners)
write_large_sql(f'{OUTPUT_DIR}/09_user_role.sql', 'user_role', ['user_id', 'role_id'], user_roles, delete_where="user_id > 1")

# Trips and Expenses (Streaming to file because it's the largest part)
# Trips and Expenses (Streaming to file because it's the largest part)
print("Generating 07_trips.sql and 08_expenses (split into 6 files)...")
trips_file = open(f'{OUTPUT_DIR}/07_trips.sql', 'w', encoding='utf-8')

trips_file.write("DELETE FROM trip;\nINSERT INTO trip (id, vehicle_id, driver_id, number_trip, manifest_number, company, origin_id, destination_id, start_date, end_date, number_of_days, status) VALUES\n")

# Multi-file expense handling
NUM_EXPENSE_FILES = 6
TOTAL_EXPECTED_TRIPS = 60522 # Pre-calculated sum based on formula
TOTAL_EXPENSES = TOTAL_EXPECTED_TRIPS * 10
EXPENSES_PER_FILE = (TOTAL_EXPENSES // NUM_EXPENSE_FILES) + 1

current_expense_file_idx = 1
current_expense_count = 0
expenses_file = None

def open_next_expense_file():
    global expenses_file, current_expense_file_idx
    if expenses_file:
        # This shouldn't be called if we didn't finish the previous file correctly with a semicolon
        expenses_file.close()
    
    file_path = f'{OUTPUT_DIR}/08_expenses_{current_expense_file_idx}.sql'
    expenses_file = open(file_path, 'w', encoding='utf-8')
    if current_expense_file_idx == 1:
        expenses_file.write("DELETE FROM expense;\n")
    
    expenses_file.write("INSERT INTO expense (vehicle_id, trip_id, category_id, amount, expense_date, description) VALUES\n")
    current_expense_file_idx += 1

open_next_expense_file()

# Re-traverse Owners and Vehicles to generate trips
v_ptr = 0
global_trip_id = 1
global_expense_id = 0

for i in range(1, OWNERS_COUNT + 1):
    owner_v_count = i * 3
    for v_idx in range(1, owner_v_count + 1):
        vid = v_ptr + v_idx
        is_heavy = (v_idx == 1) # One vehicle per owner has 400 trips
        trip_count = 400 if is_heavy else 251
        
        # approximate driver_id (1:1 with vehicle_id in this script)
        did = vid 
        
        for t_idx in range(1, trip_count + 1):
            is_last_trip = (t_idx == trip_count)
            is_glob_last_trip = (global_trip_id == TOTAL_EXPECTED_TRIPS)
            
            trip_status = 'En Curso' if is_last_trip else 'Completado'
            start_date = datetime.datetime(2024, 1, 1) + datetime.timedelta(days=t_idx)
            end_date = start_date + datetime.timedelta(hours=8)
            end_str = 'NULL' if is_last_trip else f"'{end_date.strftime('%Y-%m-%d %H:%M:%S')}'"
            
            trip_row = f"({global_trip_id}, {vid}, {did}, {t_idx}, 'MAN-{global_trip_id}', 'Company Test', {get_city_id()}, {get_city_id()}, '{start_date.strftime('%Y-%m-%d %H:%M:%S')}', {end_str}, 1, '{trip_status}')"
            trips_file.write(f"{trip_row}{';' if is_glob_last_trip else ','}\n")
            
            # 10 Expenses per trip
            for e_idx in range(1, 11):
                global_expense_id += 1
                current_expense_count += 1
                
                # Check if we need to switch to next file
                # But only if we are NOT at the very last expense of the entire generation
                is_last_global_expense = (global_expense_id == TOTAL_EXPENSES)
                is_last_in_file = (current_expense_count >= EXPENSES_PER_FILE and not is_last_global_expense)
                
                # Handle semicolon/comma
                separator = ';' if (is_last_global_expense or is_last_in_file) else ','
                
                cat_id = random.choice([1, 2, 4])
                amount = random.randint(50, 500)
                exp_row = f"({vid}, {global_trip_id}, {cat_id}, {amount}.00, '{start_date.strftime('%Y-%m-%d')}', 'Gasto {e_idx}')"
                expenses_file.write(f"{exp_row}{separator}\n")
                
                if is_last_in_file:
                    open_next_expense_file()
                    current_expense_count = 0
            
            global_trip_id += 1
            
    v_ptr += owner_v_count

trips_file.close()
if expenses_file:
    expenses_file.close()

print(f"Successfully generated all SQL files in {OUTPUT_DIR}")
print(f"Total Trips: {global_trip_id - 1}")
