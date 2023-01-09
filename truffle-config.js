const HDWalletProvider = require('@truffle/hdwallet-provider');
module.exports = {
  networks: {
    loc_development_development: {
      network_id: "*",
      port: 8545,
      host: "127.0.0.1"
    },
    loc_localganache_localganache: {
      network_id: "*",
      port: 7545,
      host: "127.0.0.1"
    },
    goerli: {
        provider: () => {
          return new HDWalletProvider("puppy mesh shield siren hidden price mountain eyebrow erode crunch orchard canal", 'https://goerli.infura.io/v3/53711b8a03334de1bcd4d4af5ef3f7a4')
        },
        network_id: '5', // eslint-disable-line camelcase
        gas: 4465030,
        gasPrice: 10000000000,
    },
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.17"
    }
  }
};
