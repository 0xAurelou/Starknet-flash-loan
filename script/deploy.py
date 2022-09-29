import asyncio
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
from starknet_py.net.networks import TESTNET

FILE = ['contracts/test_atomic.cairo']

async def deploy():
    client = GatewayClient(TESTNET)
    print("⏳ Deploying Contract...")
    contract = await Contract.deploy(
        client=client,
        compilation_source=FILE,
    )
    print(f'✨ Contract deployed at {hex(contract.deployed_contract.address)}')
    await contract.wait_for_acceptance()
    return (contract)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(deploy())