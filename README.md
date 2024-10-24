## 💻 한밭대학교 컴퓨터공학과 ColdBrew 팀 ☕

---

### 🙏 팀 구성 및 역할 분담

<div style="display: flex; justify-content: space-evenly; align-items: center;">
  <figure style="text-align: center;">
    <img src="img/wh.jpg" width="200" style="border-radius: 50%; box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);">
    <figcaption><strong>이원호</strong><br>20217144<br>Experimental Analysis</figcaption>
  </figure>
  
  <figure style="text-align: center;">
    <img src="img/sj.jpg" width="200" style="border-radius: 50%; box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);">
    <figcaption><strong>이승주</strong><br>20191745<br>Algorithm Development</figcaption>
  </figure>
</div>

---

### 📊 실험 분석
| 역할                | 사용 도구                                                                                                                                                                                                                                                |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 시뮬레이션           | ![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)                                                                                                                                          |
| 데이터               | ![CSV](https://img.shields.io/badge/CSV-003B57.svg?&style=for-the-badge&logo=csv&logoColor=white) ![Database](https://img.shields.io/badge/Database-FFCA28.svg?&style=for-the-badge&logo=database&logoColor=white)       |
| 프로그래밍 언어      | ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) ![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)                                     |
| 장치                | ![F450 Drone](https://img.shields.io/badge/F450%20Drone-000000?style=for-the-badge&logo=drone&logoColor=white)                                                                                                                                        |

---

### 📈 알고리즘 개발
| 역할                | 사용 도구                                                                                                                                                                                                                                                |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 시뮬레이션           | ![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)                                                                                                                                          |
| 데이터               | ![CSV](https://img.shields.io/badge/CSV-003B57.svg?&style=for-the-badge&logo=csv&logoColor=white) ![Database](https://img.shields.io/badge/Database-FFCA28.svg?&style=for-the-badge&logo=database&logoColor=white)      |
| 프로그래밍 언어      | ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) ![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)                                     |
| 알고리즘 개발        | ![A* Algorithm](https://img.shields.io/badge/A*-Algorithm-FF5733?style=for-the-badge&logoColor=white)                                                                                                    |

---

## 1. 프로젝트 소개 및 필요성

<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="img/전쟁상황 통신시스템 파괴.jpg" width="400" style="border-radius: 10px;">
  <img src="img/지형적 제한.jpg" width="400" style="border-radius: 10px;">
</div>

이 프로젝트는 전시 상황에서 기지국이 파괴된 경우, 드론이 임시 기지국 역할을 하여 제한된 비행 시간 내 최적의 통신 성능을 제공할 수 있는 비행 경로의 필요성을 증명하는 실험을 진행했습니다.

---

## 2. 기존 해결책의 문제

### 🪫 배터리 수명과 운영 시간의 한계
드론은 배터리 용량의 한계로 장시간 운용이 어렵습니다.

### 📡 통신 범위 및 성능의 제한
드론의 위치와 고도에 따라 통신 범위와 신호 강도가 변동할 수 있으며, 지형적 장애물로 인해 신호가 차단될 수 있습니다.

---

## 3. 최적의 통신 성능을 제공하는 경로 실험 및 필요성 증명

### 1️⃣ 라즈베리파이와 Jetson Nano를 사용한 통신 성능 실험
<div style="text-align: center;">
  <img src="img/라즈베리파이&젯슨.png" width="700" style="border-radius: 10px;">
</div>

### 2️⃣ 다양한 비행 경로 측정
<div style="text-align: center;">
  <img src="img/다양한 비행경로.jpg" width="700" style="border-radius: 10px;">
</div>

### 3️⃣ 1000번 시뮬레이션 결과
<div style="text-align: center;">
  <img src="img/1000번 시뮬레이션 case 결과물.jpg" width="1000" style="border-radius: 10px;">
</div>

---

## 4. 경로에 장애물이 있는 경우 (A* 알고리즘)

### 🅰️ 2D A* 경로
<div style="text-align: center;">
  <img src="img/2D path.png" width="700" style="border-radius: 10px;">
</div>

### 🅱️ 3D A* 경로
<div style="text-align: center;">
  <img src="img/3D path.png" width="700" style="border-radius: 10px;">
</div>

---

## 5. 결론

MATLAB과 시뮬레이션을 통해 통신 성능을 비교하여 최적 경로의 필요성을 증명하였으며, 왕복 비행 시간과 통신 시간의 반비례 관계를 밝혀 최적 성능을 달성할 수 있는 경로를 도출했습니다.

---

## 6. 프로젝트 성과 🏆

- 📕 2024 KICS 한국통신학회 하계종합학술발표회
- 📘 2024 KICS 한국통신학회 추계종합학술발표회
