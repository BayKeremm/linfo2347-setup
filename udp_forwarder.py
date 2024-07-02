import socket

# Define the host IP, VM IP, and the port numbers
HOST_IP = '192.168.1.28'  # Replace with your host IP
VM_IP = '10.211.55.16'    # Replace with your VM IP
HOST_PORT = 1234          # The port on which to listen on the host
VM_PORT = 53              # The VM is the nameserver in the lab so it listens to default DNS port 53 

# Create two UDP sockets: one for receiving from host and another for receiving from VM
sock_host = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_vm = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Bind the socket to the host IP and port
sock_host.bind((HOST_IP, HOST_PORT))

print(f"Listening on {HOST_IP}:{HOST_PORT} and forwarding to {VM_IP}:{VM_PORT}")

try:
    while True:
        # Receive data from the host IP
        data, addr = sock_host.recvfrom(1024)  # Buffer size is 1024 bytes
        print(f"Received message: {data} from {addr}")

        # Forward the data to the VM IP
        sock_vm.sendto(data, (VM_IP, VM_PORT))
        print(f"Forwarded message to {VM_IP}:{VM_PORT}")

        # Receive the response from the VM
        vm_response, vm_addr = sock_vm.recvfrom(1024)
        print(f"Received response from VM: {vm_response} from {vm_addr}")

        # Send the response back to the original sender
        sock_host.sendto(vm_response, addr)
        print(f"Forwarded response back to {addr}")

except KeyboardInterrupt:
    print("Server stopped by user")

finally:
    # Close the sockets
    sock_host.close()
    sock_vm.close()

