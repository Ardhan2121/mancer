# Personal Vault (Brankas Pribadi dengan Time Lock)

## Deskripsi

**Personal Vault** adalah smart contract Ethereum yang berfungsi sebagai brankas tabungan pribadi dengan mekanisme **time lock**. Seluruh ETH yang disimpan di dalam contract tidak dapat ditarik hingga waktu yang telah ditentukan (`unlockTime`) tercapai.

Contract ini bertujuan untuk membantu pengguna menyimpan dana dengan disiplin tanpa bergantung pada pihak ketiga.

---

# Fitur

## 1. Deposit

Pemilik contract dapat mengirimkan ETH ke dalam vault.

### Input

- ETH (`msg.value`)

### Proses

- Menerima ETH yang dikirim.
- Menyimpan ETH di saldo contract.
- Mengirim event:

```solidity
Deposit(address sender, uint256 amount)
```

---

## 2. Withdraw

Pemilik dapat menarik seluruh saldo vault setelah waktu penguncian berakhir.

### Syarat

- Pemanggil adalah owner.
- Waktu saat ini sudah melewati `unlockTime`.
- Saldo contract lebih dari 0.

### Proses

- Memeriksa waktu penguncian.
- Memeriksa kepemilikan contract.
- Mengirim seluruh saldo ke owner.
- Mengirim event:

```solidity
Withdrawal(uint256 amount, uint256 timestamp)
```

---

## 3. Extend Lock

Pemilik dapat memperpanjang waktu penguncian.

### Input

```text
newTime (uint256)
```

### Syarat

- Pemanggil adalah owner.
- `newTime` harus lebih besar dari `unlockTime`.

### Proses

- Memperbarui `unlockTime`.
- Mengirim event:

```solidity
LockExtended(uint256 newUnlockTime)
```

---

# Struktur Data

```solidity
address public owner;
uint256 public unlockTime;
```

---

# Event

```solidity
event Deposit(address indexed sender, uint256 amount);
event Withdrawal(uint256 amount, uint256 timestamp);
event LockExtended(uint256 newUnlockTime);
```

---

# Custom Error

```solidity
error FundsLocked();
error NotOwner();
error InvalidUnlockTime();
```

Custom error digunakan agar penggunaan gas lebih efisien dibandingkan `require()` dengan string.

---

# Modifier

```solidity
onlyOwner
```

Modifier ini memastikan hanya pemilik contract yang dapat mengakses fungsi tertentu.

---

# Constructor

Saat contract dibuat:

- Menyimpan alamat deployer sebagai `owner`.
- Menyimpan waktu buka (`unlockTime`).
- Memastikan waktu buka berada di masa depan.

---

# Alur Kerja

```text
Deploy Contract
        │
        ▼
Set Owner & Unlock Time
        │
        ▼
Deposit ETH
        │
        ▼
Dana Terkunci
        │
        ├───────────────┐
        │               │
block.timestamp         │
< unlockTime            │
        │               │
        ▼               │
Withdraw Gagal          │
                        │
block.timestamp >= unlockTime
        │
        ▼
Withdraw Berhasil
```

---

# Keamanan

- Hanya owner yang dapat melakukan withdraw.
- Dana tidak dapat diambil sebelum waktu penguncian berakhir.
- Waktu penguncian hanya dapat diperpanjang, tidak dapat dipersingkat.
- Menggunakan custom error agar lebih hemat gas.

---

# Kesimpulan

Personal Vault merupakan implementasi sederhana smart contract Ethereum yang memanfaatkan akses berbasis owner, mekanisme time lock, event, modifier, serta custom error untuk membuat sistem penyimpanan ETH yang aman dan transparan.
