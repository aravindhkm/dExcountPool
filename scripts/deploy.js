
const hre = require("hardhat");

async function main() {
  const dispool = await hre.ethers.getContractFactory("dExcountPoolDeployer");
  const DisCount = await dispool.deploy("0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8","0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8");

  await DisCount.deployed();

  console.log("DisCount.address deployed to:", DisCount.address);

  await hre.run("verify:verify", {
    address: DisCount.address,
    constructorArguments: ["0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8","0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8"],
  });


  // await hre.run("verify:verify", {
  //   address: "0xA93aB9de58Eeb42417815B53CeCc21C54d5876b1",
  //   constructorArguments: ["0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8","0x17Ca0928871b2dB9dd3B2f8b27148a436C24Baa8"],
  // });



  //   const dispool = await hre.ethers.getContractFactory("MyToken");
  // const DisCount = await dispool.deploy();

  // await DisCount.deployed();
  // await hre.run("verify:verify", {
  //   address: DisCount.address,
  //   constructorArguments: [],
  // });


  // const dispool = await hre.ethers.getContractFactory("Exchange");
  // const DisCount = await dispool.deploy("0x233aE2AE4A5196164b43876dD13771Ab4f5c205d");

  // await DisCount.deployed();
  // await hre.run("verify:verify", {
  //   address: "0x104fA8Bd71f127B908667671Ebd8FaAA404cd036",
  //   constructorArguments: [],
  // });

  //     const dispool = await hre.ethers.getContractFactory("BreezeToken");
  // const DisCount = await dispool.deploy();

  // await DisCount.deployed();
  // await hre.run("verify:verify", {
  //   address: "0x670D6b12a75C23264b022eb29842DE55C944c260",
  //   constructorArguments: [],
  // });


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});