const ContainerExport = artifacts.require("ContainerExport.sol");
const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");

contract("ContainerExport", (accounts) => {
    //setting up the instance
    let instance;

    //setting up some accounts
    const [sender, one, two, three] = accounts;

    //set password
    const pw1 = "test1234";
    const pw2 = "1234test";

    //Set up a new contract before test
    beforeEach("set up contract", async () => {
      //sender deploys the contract
      instance =  await ContainerExport.new({from: sender});
    });

    it("test1: should be able to register a company", async () => {
      const company = one;
      const registerCompany = await instance.registerCompany(company, {from: one});
      const { logs } = registerCompany;
      const registerCompanyEvent = registerCompany.logs[0];
      //check if transaction was successful
      truffleAssert.eventEmitted(registerCompany, "LogCompanyRegistered");
      //assert.strictEqual(result.receipt.status, true);
      assert.strictEqual(registerCompanyEvent.args.company, company, "Not account one");
    });

    it("test2: should be able to deregister a company", async () => {
      const company = one;
      await instance.registerCompany(company, {from: one});
      const deregisterCompany = await instance.deregisterCompany(company, {from: sender});
      const { logs } = deregisterCompany;
      const deregisterCompanyEvent = deregisterCompany.logs[0];
      //check if transaction was successful
      truffleAssert.eventEmitted(deregisterCompany, "LogCompanyDeregistered");
      //assert.strictEqual(result.receipt.status, true);
      assert.strictEqual(deregisterCompanyEvent.args.company, company, "Not account one");
    });

    it("test3: should be able to create a new container", async () => {
      const containerName = "CTXU 123456 1"
      const containerId = 1;
      const hash = await instance.generateHash(one, web3.utils.toHex(pw1));
      const createContainer = await instance.createContainer(hash, containerName, {from: one});
      const { logs } = createContainer;
      const createContainerEvent = createContainer.logs[0];
      //check if transaction was successful
      truffleAssert.eventEmitted(createContainer, "LogNewContainer");
      //assert.strictEqual(result.receipt.status, true);
      assert.strictEqual(createContainerEvent.args.hash, hash, "hash problem");
      assert.strictEqual(createContainerEvent.args.containerName, containerName, "container name isn't right");
      assert.strictEqual(createContainerEvent.args.containerId.toString(), containerId.toString(), "containerId  isn't right");
    })

    it("test4: LogTransfer-event should be emitted", async() => {
      //setting the hash
      const hash = await instance.generateHash(one, web3.utils.toHex(pw1));
      const containerName = "CTXU 123456 1"
      const containerId = 2;
      await instance.createContainer(hash, containerName, {from: one});
      const from = one;
      const to = two;
      //call the contract from sender
      const transferContainer = await instance.transferContainer(hash, from, to, {from: one});

      const { logs } = transferContainer;
      const transferContainerEvent = transferContainer.logs[0];
      truffleAssert.eventEmitted(transferContainer, "LogTransfer");

      assert.strictEqual(transferContainerEvent.args.hash, hash, "hash problem");
      assert.strictEqual(transferContainerEvent.args.from, one, "sender isn't right");
      assert.strictEqual(transferContainerEvent.args.to, two, "receiver is not right");
      assert.strictEqual(transferContainerEvent.args.containerId.toString(), containerId.toString() , "ContainerId is not right");
     });


     it("test5: transfer container from wrong account should not work", async() => {
       const hash = await instance.generateHash(one, web3.utils.toHex(pw1));
       const containerName = "CTXU 123456 1"
       await instance.createContainer(hash, containerName, {from: one});
       const from = two;
       const to = one;
       await truffleAssert.fails(instance.transferContainer(hash, from, to, {from: two}));
      });

      it("test6: register a company a second time should not work", async() => {
        const company = one;
        const registerCompany = await instance.registerCompany(company, {from: one});
        await truffleAssert.fails(instance.registerCompany(company, {from: one}));
       });
})
