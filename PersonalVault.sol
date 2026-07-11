// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * PersonalVault
 * Smart contract sederhana untuk menyimpan ETH dengan sistem time lock.
 * Dana hanya dapat ditarik oleh owner setelah waktu unlock tercapai.
 */
contract PersonalVault {

    // Menyimpan alamat pemilik contract
    address public owner;

    // Menyimpan waktu (timestamp) kapan dana dapat ditarik
    uint256 public unlockTime;

    // Event yang dipanggil ketika owner melakukan deposit ETH
    event Deposit(address indexed sender, uint256 amount);

    // Event yang dipanggil ketika owner berhasil menarik seluruh dana
    event Withdrawal(uint256 amount, uint256 timestamp);

    // Event yang dipanggil ketika waktu penguncian diperpanjang
    event LockExtended(uint256 newUnlockTime);

    // Custom error jika dana masih dalam masa penguncian
    error FundsLocked();

    // Custom error jika fungsi dipanggil selain oleh owner
    error NotOwner();

    // Custom error jika waktu unlock baru tidak valid
    error InvalidUnlockTime();

    /*
     * Modifier onlyOwner
     * Memastikan hanya owner yang dapat menjalankan fungsi tertentu.
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    /*
     * Constructor
     *
     * Akan dijalankan satu kali saat contract di-deploy.
     * - Menyimpan alamat deployer sebagai owner.
     * - Menyimpan waktu unlock.
     * - Memastikan unlockTime berada di masa depan.
     */
    constructor(uint256 _unlockTime) payable {
        require(
            _unlockTime > block.timestamp,
            "Unlock time must be in the future"
        );

        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    /*
     * deposit()
     *
     * Fungsi untuk menyimpan ETH ke dalam vault.
     * Fungsi bersifat payable sehingga dapat menerima ETH.
     * Setiap deposit akan memicu event Deposit.
     */
    function deposit() external payable onlyOwner {
        emit Deposit(msg.sender, msg.value);
    }

    /*
     * withdraw()
     *
     * Mengirim seluruh saldo contract kepada owner.
     *
     * Syarat:
     * - Hanya owner yang boleh memanggil.
     * - Waktu sekarang harus melewati unlockTime.
     * - Contract harus memiliki saldo.
     */
    function withdraw() external onlyOwner {

        // Cek apakah masa penguncian sudah berakhir
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        // Ambil seluruh saldo contract
        uint256 amount = address(this).balance;

        // Pastikan masih ada dana yang dapat ditarik
        require(amount > 0, "No funds");

        // Transfer seluruh saldo ke owner
        payable(owner).transfer(amount);

        // Catat aktivitas withdraw melalui event
        emit Withdrawal(amount, block.timestamp);
    }

    /*
     * extendLock()
     *
     * Memperpanjang waktu penguncian.
     *
     * Waktu baru harus lebih besar dari unlockTime saat ini,
     * sehingga owner tidak dapat mempercepat pencairan dana.
     */
    function extendLock(uint256 newTime) external onlyOwner {

        // Validasi agar waktu tidak bisa dipersingkat
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        // Simpan waktu unlock yang baru
        unlockTime = newTime;

        // Catat perubahan melalui event
        emit LockExtended(newTime);
    }
}
