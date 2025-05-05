Instalasi Kubernetes di AWS
1. Lakukan VPC Peering Connection

    Ikuti tutorial ini: [Tutorial](https://www.youtube.com/watch?v=0mRA-KuXI2s).

2. Assign Elastic IP di Node Master

    Tetapkan Elastic IP ke node master.

3. (Opsional) Rename Hostctl

    Ubah nama hostctl untuk keperluan estetik.

4. Connect SSH ke Semua Instance (Pakai Keygen)

    Sambungkan ke semua instance menggunakan SSH dengan keygen.

5. Masukkan Repo ke AWS
   ```
   git clone https://github.com/Jeijesh69/KubernetesInstallation.git
   cd KubernetesInstallation

6. Jalankan Script di Master
   ```
   cd script
   chmod +x setup_master.sh
   ./setup_master.sh

7. Jalankan Script di Masing-Masing Worker
   ```
   chmod +x setup_worker.sh
   ./setup_worker.sh

8. Worker Bergabung ke Master
   Jalankan perintah berikut di worker untuk bergabung dengan master:
   ```
   kubeadm token create --print-join-command
   ```
   Tambahkan sudo di awal perintah dan --cri-socket unix:///var/run/cri-dockerd.sock di akhir.

9. Instalasi Calico untuk Node
   Pastikan semua node sudah terhubung, lalu jalankan script ini di master:
   ```
   chmod +x calico_master.sh
   ./calico_master.sh

10. Apply Metric Server
    ```
    kubectl apply -f metrics-server.yaml

11. Instalasi Kubernetes Dashboard (Master Only)
   ```
    chmod +x kubernetes_dashboard_master.sh
   ./kubernetes_dashboard_master.sh
   ```

Dashboard Siap Digunakan
