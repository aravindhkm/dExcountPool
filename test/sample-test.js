const {
  expectEvent, // Assertions for emitted events
  time,
  expectRevert,
} = require("@openzeppelin/test-helpers");
var chai = require("chai");
 var expect = chai.expect;
const WBNB = artifacts.require("WBNB");
const PancakeRouter = artifacts.require("PancakeRouter");
const PancakeFacotry = artifacts.require("PancakeFactory");
const TestToken = artifacts.require("GalaxyPad");
const LpPair = artifacts.require("PancakePair");

contract("NFT-Exchange", (accounts) => {
  const zeroAddress = "0x0000000000000000000000000000000000000000";
  const owner = accounts[0];
  const platFromOwner = accounts[1];
  const testAccount1 = accounts[6];
  const testAccount2 = accounts[7];
  const testAccount3 = accounts[8];
  const testAccount4 = accounts[9];
  const testAccount5 = accounts[10];
  const testAccount6 = accounts[11];
  const feeAddress = accounts[14];
  const tresury = accounts[13];
  const poolCreator1 = accounts[12];
  before(async function () {
      WETHinstance = await WBNB.new();
      pancakeFactoryInstance = await PancakeFacotry.new(feeAddress);
      pancakeRouterInstance = await PancakeRouter.new( pancakeFactoryInstance.address,WETHinstance.address);
      tokenInstance = await TestToken.new(pancakeFactoryInstance.address,WETHinstance.address);
  });

  describe("add liquidity", () => {
      let tokenQuantity = "10000000000000000000000";
      let tAmountq = "1000000000000000000000";

      it("add liqudity", async function () {

          await tokenInstance.approve(pancakeRouterInstance.address,tokenQuantity, {
              from:owner
          });

          console.log("init hash",await pancakeRouterInstance.address);

          await pancakeRouterInstance.addLiquidityETH(
              tokenInstance.address,
              tokenQuantity,
              0,
              0,
              testAccount1,
              testAccount1,{
                  from: owner,
                  value: 10e18
              }
          )

          await tokenInstance.transfer(testAccount1,tAmountq, {
            from:owner
        });
        await tokenInstance.transfer(testAccount1,tAmountq, {
          from:owner
      });

          await tokenInstance.approve(pancakeRouterInstance.address,tAmountq, {
            from:testAccount1
        });


              
          let result1 = await pancakeRouterInstance.getAmountsOut(tAmountq,[tokenInstance.address,WETHinstance.address]);

          console.log("result", (result1[0]).toString(),(result1[1]).toString());

          await pancakeRouterInstance.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tAmountq,
            0,
            [tokenInstance.address,WETHinstance.address],
            testAccount1,
            testAccount1, {
              from : testAccount1
            }
          )


          // let len = await pancakeFactoryInstance.allPairsLength();
          // let lpAddr = await pancakeFactoryInstance.allPairs(0);
          // const pairInstance = await LpPair.at(lpAddr);
          
          // let lpBalance = await pairInstance.balanceOf(testAccount1);
          
        //   console.log("total Supply", Number(await pairInstance.totalSupply()));
        //   console.log("adddress 1 Lp balance", Number( await pairInstance.balanceOf(testAccount1)));
        //   console.log("adddress 2 Lp balance", Number( await pairInstance.balanceOf(testAccount2)));
        // // let getReserve = await pairInstance.getReserves();
        //   console.log("Get Reserve Token A", Number(getReserve[0]/1e18));
        //   console.log("Get Reserve Token B", Number(getReserve[1]/1e18));
        //   console.log("");
        //   console.log("");
        //   console.log("");
      })  
  })

  // describe("pool add", () => {
  //   let tokenQuantity = "10000000000000000000000";

  //   it("create pool", async function () {
  //       await tokenInstance.mint(poolCreator1,tokenQuantity, {
  //           from:owner
  //       });

  //       await tokenInstance.approve(mainInstance.address,tokenQuantity, {
  //           from:poolCreator1
  //       });


  //       let exacttime = Number(await time.latest()) + Number(await time.duration.weeks(1));

  //       // console.log("exact", Number(exacttime))
  //       await mainInstance.createPool(tokenInstance.address,
  //           "10000000000000000000000",
  //           Number(await time.latest()) + Number(1000),
  //           exacttime,
  //           30,
  //           poolCreator1,
  //           "100000000000000000",
  //           "10000000000000000000",
  //           70,{
  //             from:poolCreator1,
  //             value: 0.4e18
  //       });     
        
  //       // console.log("pool", Number(await mainInstance.poolLength()));
  //   })  

  //   it("SWAP BNB", async function () {
  //     let tAmount = "100000000000000000";

  //     let result = await pancakeRouterInstance.getAmountsOut(tAmount,[WETHinstance.address,tokenInstance.address]);

  //     // console.log("result", (result[0]).toString(),(result[1]).toString());
      
  //     await mainInstance.setDiscountSale(saleInstance.address, {
  //       from: owner
  //     });

  //     // console.log("now", Number(await time.latest()))

  //     let poolAddress = await mainInstance.poolAt(0);

  //     await time.increase(86400 * 2);


  //     // console.log("Before User Balance", Number(
  //     //   await tokenInstance.balanceOf(testAccount2)
  //     // ));

  //     await saleInstance.swap(poolAddress,testAccount2,{
  //       from:testAccount2,
  //       value:tAmount
  //     })

  //     // console.log("After User Balance", (
  //       // await tokenInstance.balanceOf(testAccount2)).toString()
  //       // );

  //     let contractBal = await tokenInstance.balanceOf(poolAddress);
  //     // console.log("Remaining contract balance", (contractBal).toString());
  //   })  


  //   it("SWAP BNB", async function () {
  //     let tAmount = "100000000000000000";
  //     let tAmountq = "250000000000000000";
  //     let tokenQuantity = "1000000000000000000000000";
      

  //     let result = await pancakeRouterInstance.getAmountsOut(tAmount,[WETHinstance.address,tokenInstance.address]);

  //     // console.log("result", (result[0]).toString(),(result[1]).toString());
  
  //     // console.log("now", Number(await time.latest()))

  //     let poolAddress = await mainInstance.poolAt(0);

  //     await time.increase(86400 * 2);

  //     await saleInstance.swap(poolAddress,testAccount2,{
  //       from:testAccount2,
  //       value:tAmount
  //     })

  //     const poolInstance = await pool.at(poolAddress);
  //     // console.log("bnb balance", Number(await poolInstance.bnbBalance()))

  //     let contractBal = await tokenInstance.balanceOf(poolAddress);
  //     // console.log("Remaining contract balance", (contractBal).toString());
     
  //     await tokenInstance.mint(testAccount1,tokenQuantity, {
  //       from:owner
  //   });

  //   await tokenInstance.approve(pancakeRouterInstance.address,tokenQuantity, {
  //       from:testAccount1
  //   });

  //   console.log("init hash",await pancakeFactoryInstance.INIT_CODE_PAIR_HASH());

  //   await pancakeRouterInstance.addLiquidityETH(
  //       tokenInstance.address,
  //       tokenQuantity,
  //       0,
  //       0,
  //       testAccount1,
  //       testAccount1,{
  //           from: testAccount1,
  //           value: 10e18
  //       }
  //   )

    
  //   let result1 = await pancakeRouterInstance.getAmountsOut(tAmountq,[WETHinstance.address,tokenInstance.address]);

  //   console.log("result", (result1[0]).toString(),(result1[1]).toString());


  //     console.log("before bnb Balance", Number(await poolInstance.bnbBalance()));
  //     console.log("before token Balance", (await poolInstance.tokenBalance()).toString());

  //      await poolInstance.minimumBuyBackAmountUpdate(tAmountq,true, {from:poolCreator1});

  //     await saleInstance.swap(poolAddress,testAccount2,{
  //       from:testAccount2,
  //       value:tAmountq
  //     })

  //     console.log("after bnb Balance", Number(await poolInstance.bnbBalance()));
  //     console.log("after token Balance", (await poolInstance.tokenBalance()).toString());
  //   })  

    

  //   // it("buy back", async function () {
  //   //   let tAmount = "1000000000000000000";

  //   //   let result = await pancakeRouterInstance.getAmountsOut(tAmount,[WETHinstance.address,tokenInstance.address]);

  //   //   console.log("result", (result[0]).toString(),(result[1]).toString());
  
  //   //   let now = Number(await time.latest());

  //   //   let poolAddress = await mainInstance.poolAt(0);

  //   //   let store = await mainInstance.poolDetails(poolAddress);

  //   //   let end = Number(store.endTime);

  //   //   let timeSec = end - now; 

  //   //   console.log("Time", Number(timeSec), end,now);

  //   //   await time.increase(time.duration.seconds(timeSec));

  //   //   console.log("PlatformWalletAddress", await mainInstance.PlatformWalletAddress(),owner);

  //   //   await saleInstance.confirm(poolAddress,{
  //   //     from:poolCreator1
  //   //   })

  //   //   const poolInstance = await pool.at(poolAddress);

  //   //   console.log("bnb balance", Number(await poolInstance.bnbBalance()))

  //   //   let contractBal = await tokenInstance.balanceOf(poolAddress);
  //   //   console.log("Remaining contract balance", (contractBal).toString());

  //   //   // await saleInstance.burn(poolAddress, {from: poolCreator1});
  //   //   // console.log("bnb balance", Number(await poolInstance.bnbBalance()))
  //   //   // console.log("Remaining contract balance", (await tokenInstance.balanceOf(poolAddress)).toString())
  //   //  })  

  //   //  it("create pool", async function () {
  //   //   // let poolAddress = await mainInstance.poolAt(0);
  //   //   // const poolInstance = await pool.at(poolAddress);
  //   //   // console.log("before bnb balance", Number(await poolInstance.bnbBalance()))
  //   //   // console.log("before Remaining contract balance", (await tokenInstance.balanceOf(poolAddress)).toString())
  //   //   // await saleInstance.claim(poolAddress, {from: poolCreator1});


  //   //   // console.log("bnb balance", Number(await poolInstance.bnbBalance()))
  //   //   // console.log("Remaining contract balance", (await tokenInstance.balanceOf(poolAddress)).toString())
 
  //   //  });



    
  //  })

})