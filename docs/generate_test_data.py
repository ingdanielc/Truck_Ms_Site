import random
import datetime
import os

# Hash for '12345678'
PASS_HASH = 'fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe'

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

def write_sql_file(filename, table, columns, value_list):
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(f"DELETE FROM {table};\n")
        if not value_list:
            return
        
        # Batch insert
        f.write(f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n")
        for i, val in enumerate(value_list):
            comma = "," if i < len(value_list) - 1 else ";"
            f.write(f"{val}{comma}\n")

# Configuration
OWNERS_COUNT = 2000
TOTAL_TRIPS = 3000
OUTPUT_DIR = 'scripts/test_data'
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 1. Reference Data
with open(f'{OUTPUT_DIR}/01_reference_data.sql', 'w', encoding='utf-8') as f:
    f.write(generate_reference_data())

# 2. Users & Owners
users = []
owners = []
user_roles = []

for i in range(1, OWNERS_COUNT + 1):
    uid = i
    name = f"Owner {i}"
    email = f"owner{i}@test.com"
    users.append(f"({uid}, '{name}', '{email}', '{PASS_HASH}', 'Activo')")
    owners.append(f"({i}, 1, 'DOC-O-{i}', '{name}', '{email}', '3000000{i:03}', {random.randint(1,100)}, {random.randint(1,2)}, '1980-01-01', {uid}, 50, FALSE)")
    # Owner role is 2
    user_roles.append(f"({uid}, 2)")

# 3. Drivers & Vehicles (per owner)
drivers = []
vehicles = []
vehicle_owners = []
driver_user_start = OWNERS_COUNT + 1

for i in range(1, OWNERS_COUNT + 1):
    # 2 drivers per owner
    d_ids = []
    for d_idx in range(1, 3):
        did = (i-1)*2 + d_idx
        duid = driver_user_start + did - 1
        dname = f"Driver {did}"
        demail = f"driver{did}@test.com"
        users.append(f"({duid}, '{dname}', '{demail}', '{PASS_HASH}', 'Activo')")
        drivers.append(f"({did}, 1, 'DOC-D-{did}', '{dname}', '{demail}', '3100000{did:03}', {random.randint(1,100)}, {random.randint(1,2)}, '1990-01-01', {random.randint(1,2)}, 2000000, 'C3', 'LIC-{did}', '2030-01-01', {duid}, {i})")
        # Driver role is 3
        user_roles.append(f"({duid}, 3)")
        d_ids.append(did)
    
    # 2 vehicles per owner
    for v_idx in range(1, 3):
        vid = (i-1)*2 + v_idx
        # Plate format ABC-123
        plate = f"ABC-{vid:03}"
        status = 'Activo' if random.random() > 0.1 else 'En Mantenimiento'
        vehicles.append(f"({vid}, '{plate}', {d_ids[v_idx-1]}, {random.randint(1,4)}, 'Model-T', 2020, 'White', '{status}')")
        vehicle_owners.append(f"({vid}, {i}, 100.00, TRUE)")

# 4. Trips
trips = []
expenses = []
v_trips = {} # To track last trip per vehicle

for i in range(1, TOTAL_TRIPS + 1):
    vid = random.randint(1, len(vehicles))
    did = vehicles[vid-1].split(', ')[2] # approximate but works for simulation
    
    if vid not in v_trips: v_trips[vid] = []
    
    start = datetime.datetime(2025, 1, 1) + datetime.timedelta(days=random.randint(0, 30))
    end = start + datetime.timedelta(days=2)
    
    t_data = {'id': i, 'vid': vid, 'did': did, 'start': start, 'end': end, 'status': random.choice(['Completado', 'Pendiente'])}
    v_trips[vid].append(t_data)

# Fix last trip status
for vid in v_trips:
    v_trips[vid][-1]['status'] = 'En Curso'
    v_trips[vid][-1]['end'] = None

# Flatten and generate inserts
for vid in v_trips:
    for t in v_trips[vid]:
        end_str = f"'{t['end'].strftime('%Y-%m-%d %H:%M:%S')}'" if t['end'] else 'NULL'
        trips.append(f"({t['id']}, {t['vid']}, {t['did']}, 1, 'MAN-{t['id']}', 'Company X', {random.randint(1,100)}, {random.randint(1,100)}, '{t['start'].strftime('%Y-%m-%d %H:%M:%S')}', {end_str}, 2, '{t['status']}')")
        # 3 expenses per trip
        expenses.append(f"({t['vid']}, {t['id']}, 1, 1000.00, '{t['start'].strftime('%Y-%m-%d')}', 'Combustible')")
        expenses.append(f"({t['vid']}, {t['id']}, 2, 200.00, '{t['start'].strftime('%Y-%m-%d')}', 'Peaje')")
        expenses.append(f"({t['vid']}, {t['id']}, 4, 150.00, '{t['start'].strftime('%Y-%m-%d')}', 'Viaticos')")

# Final sorting by ID relative to lists if needed, but not critical for simple inserts
# Write Files
write_sql_file(f'{OUTPUT_DIR}/02_users.sql', 'users', ['id', 'name', 'email', 'password', 'status'], users)
write_sql_file(f'{OUTPUT_DIR}/03_owners.sql', 'owner', ['id', 'document_type_id', 'document_number', 'name', 'email', 'cell_phone', 'city_id', 'gender_id', 'birthdate', 'user_id', 'max_vehicles', 'is_driver'], owners)
write_sql_file(f'{OUTPUT_DIR}/04_drivers.sql', 'driver', ['id', 'document_type_id', 'document_number', 'name', 'email', 'cell_phone', 'city_id', 'gender_id', 'birthdate', 'salary_type_id', 'salary', 'license_category', 'license_number', 'license_expiry', 'user_id', 'owner_id'], drivers)
write_sql_file(f'{OUTPUT_DIR}/05_vehicles.sql', 'vehicle', ['id', 'plate', 'current_driver_id', 'vehicle_brand_id', 'model', 'year', 'color', 'status'], vehicles)
write_sql_file(f'{OUTPUT_DIR}/06_vehicle_owner.sql', 'vehicle_owner', ['vehicle_id', 'owner_id', 'ownership_percentage', 'is_active'], vehicle_owners)
write_sql_file(f'{OUTPUT_DIR}/07_trips.sql', 'trip', ['id', 'vehicle_id', 'driver_id', 'number_trip', 'manifest_number', 'company', 'origin_id', 'destination_id', 'start_date', 'end_date', 'number_of_days', 'status'], trips)
write_sql_file(f'{OUTPUT_DIR}/08_expenses.sql', 'expense', ['vehicle_id', 'trip_id', 'category_id', 'amount', 'expense_date', 'description'], expenses)
write_sql_file(f'{OUTPUT_DIR}/09_user_role.sql', 'user_role', ['user_id', 'role_id'], user_roles)

print("Succesfully generated all SQL files in scripts/test_data/")
