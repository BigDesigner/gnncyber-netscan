import sqlite3
import os

db_path = 'assets/cve_db.sqlite'
os.makedirs(os.path.dirname(db_path), exist_ok=True)

# Remove if exists to recreate
if os.path.exists(db_path):
    os.remove(db_path)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Create table
cursor.execute('''
CREATE TABLE cve_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service TEXT NOT NULL,
    version TEXT NOT NULL,
    cve_id TEXT NOT NULL,
    cvss_score REAL NOT NULL,
    severity TEXT NOT NULL
)
''')

# Mock data for top most common network vulnerabilities
vulnerabilities = [
    # FTP
    ('vsftpd', '2.3.4', 'CVE-2011-2523', 9.8, 'CRITICAL'),
    ('ProFTPD', '1.3.5', 'CVE-2015-3306', 9.8, 'CRITICAL'),
    ('ProFTPD', '1.3.3c', 'CVE-2010-4221', 10.0, 'CRITICAL'),
    ('Pure-FTPd', '1.0.49', 'CVE-2019-20176', 7.5, 'HIGH'),
    
    # SSH
    ('OpenSSH', '7.2p2', 'CVE-2016-6210', 5.3, 'MEDIUM'),
    ('OpenSSH', '8.2p1', 'CVE-2020-15778', 6.8, 'MEDIUM'),
    ('OpenSSH', '9.8p1', 'CVE-2024-6387', 8.1, 'HIGH'), # regreSSHion
    ('libssh', '0.8.1', 'CVE-2018-10933', 9.1, 'CRITICAL'),
    
    # HTTP/HTTPS
    ('Apache httpd', '2.4.49', 'CVE-2021-41773', 9.8, 'CRITICAL'),
    ('Apache httpd', '2.4.50', 'CVE-2021-42013', 9.8, 'CRITICAL'),
    ('nginx', '1.14.0', 'CVE-2018-16843', 7.5, 'HIGH'),
    ('Microsoft-IIS', '6.0', 'CVE-2017-7269', 9.8, 'CRITICAL'),
    
    # SMB
    ('SMB', '1.0', 'CVE-2017-0144', 9.3, 'CRITICAL'), # MS17-010 EternalBlue
    ('Samba', '3.0.20', 'CVE-2007-2447', 10.0, 'CRITICAL'),
    ('Samba', '4.5.9', 'CVE-2017-7494', 9.8, 'CRITICAL'), # SambaCry
    
    # Remote Desktop / VNC
    ('RDP', '7.0', 'CVE-2019-0708', 9.8, 'CRITICAL'), # BlueKeep
    ('RealVNC', '4.1.1', 'CVE-2006-2369', 10.0, 'CRITICAL'),
    
    # Database
    ('MySQL', '5.5.0', 'CVE-2012-2122', 5.1, 'MEDIUM'),
    ('PostgreSQL', '9.3.0', 'CVE-2013-1899', 7.5, 'HIGH'),
]

cursor.executemany('''
INSERT INTO cve_data (service, version, cve_id, cvss_score, severity)
VALUES (?, ?, ?, ?, ?)
''', vulnerabilities)

# Index for fast lookup
cursor.execute('CREATE INDEX idx_service_version ON cve_data(service, version)')

conn.commit()
conn.close()

print(f"Successfully generated offline CVE database at: {os.path.abspath(db_path)}")
print(f"Total entries: {len(vulnerabilities)}")
