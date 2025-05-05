# Instalasi Kubernetes di AWS
1. Lakukan VPC Peering connection
   https://www.youtube.com/watch?v=0mRA-KuXI2s --> Ikutin tutorial abang yutub ini
   
2. (Opsional) Rename Hostctl

3. Connect SSH Semua Instance (pake keygen)

4. Jalanin Script ini di Master
     (link)
5. Jalanin Scipt ini di Masing-Masing Worker

6. Biar nodenya redi, instalasi calico

7. Apply metric server
kubectl apply -f metrics-server.yaml

9. Instalasi Kubernetes Dashboard pake skrip (Master only)
   
10. Apply k8s-dash
kubectl apply -f k8s-dash.yaml

Dashboard redi
