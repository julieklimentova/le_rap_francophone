const path = require('path');

module.exports = {
    entry: {app: './DataCollector.js'},
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'DataCollector.js'
    },
    target: 'async-node',
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /(node_modules)/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env'],
                        plugins: ['@babel/plugin-transform-runtime', '@babel/plugin-proposal-class-properties']
                    }
                }
            }
        ]
    },
    externals: {
        'isomorphic-fetch': 'fetch'
    }
};
