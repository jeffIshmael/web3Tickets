const hre = require('hardhat');

async function main() {
  await hre.run("compile");

  const blockTickets = await hre.ethers.deployContract('BlocTickets');
  await blockTickets.waitForDeployment();
  console.log(`BlocTickets deployed to ${blockTickets.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});