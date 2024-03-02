import { ethers, } from "hardhat";
import { expect } from "chai";
import { ETHPool } from "../typechain-types";

describe("ETHPool", function () {
    let pool: ETHPool;

    beforeEach(async function () {
        const PoolFactory = await ethers.getContractFactory("ETHPool");
        pool = await PoolFactory.deploy();
        await pool.waitForDeployment();
    });

    it("should deposit ETH", async function () {
        await pool.deposit({ value: ethers.parseEther("1") });
        expect(await pool.totalDeposits()).to.equal(ethers.parseEther("1"));
    });

    it("should withdraw ETH", async function () {
        await pool.deposit({ value: ethers.parseEther("1") });
        await pool.withdraw(ethers.parseEther("0.5"));
        expect(await pool.totalDeposits()).to.equal(ethers.parseEther("0.5"));
    });
});
