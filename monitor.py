#!/usr/bin/env python3
import subprocess, requests

CHECKS = [
    ("http://127.0.0.1:8000", "telofarm-daphne"),
    ("https://seong-ju.telofarm.net", "telofarm-tunnel"),
]

def check_service(url, service):
    try:
        res = requests.get(url, timeout=3)
        if res.status_code != 200:
            raise Exception("Bad status")
    except:
        print(f"❌ {service} 실패 → 재시작")

        subprocess.run(["sudo", "systemctl", "restart", service])

        # daphne 죽었으면 controller도 같이 재시작
        if service == "telofarm-daphne":
            subprocess.run(["sudo", "systemctl", "restart", "telofarm-controller"])

        
if __name__ == "__main__":
    for url, svc in CHECKS:
        check_service(url, svc)