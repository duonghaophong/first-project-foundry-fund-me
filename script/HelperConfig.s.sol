// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    // Dung struct o day chi de de bao tri code, cung nhu la tinh gon code hon

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetwork();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetNetwork();
        } else {
            activeNetworkConfig = getOrCreatAnvilNetwork();
        }
    }

    function getSepoliaNetwork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaNetwork = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetwork;
    }

    function getMainnetNetwork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetNetwork = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetNetwork;
    }

    function getOrCreatAnvilNetwork() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilNetwork = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilNetwork;
    }
}
