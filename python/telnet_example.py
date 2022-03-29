import telnetlib

host = "128.128.12.86"
user = "root"
password = "jvtsmart123"

tn = telnetlib.Telnet(host)

tn.read_until(b"login: ")
tn.write(user.encode('ascii') + b"\n")

tn.read_until(b"Password: ")
tn.write(password.encode('ascii') + b"\n")



tn.write(b"uptime\n ")
tn.write(b"exit\n")

print(tn.read_all().decode('ascii'))


#tn.read_until(b"Password: ")
#tn.write(password.encode('ascii') + b"\n")
#tn.write(b"ls\n")
#tn.write(b"exit\n")
#print(tn.read_all().decode('ascii'))