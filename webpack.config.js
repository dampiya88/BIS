/*
        Name        : /v1/views/reports/src/webpack.config.js
        Date        : February 20, 2019
        Author      : RRK
*/

const webpack = require('webpack');
const path = require('path');
var PACKAGE = require('./package.json');
const { getIfUtils, removeEmpty } = require('webpack-config-utils');
/**
 * https://github.com/ryandrewjohnson/boilerplate/tree/master/webpack
 * https://hackernoon.com/webpack-creating-dynamically-named-outputs-for-wildcarded-entry-files-9241f596b065
 */
module.exports = env => {
  const { ifProd, ifNotProd } = getIfUtils(env);
  const moduleName = PACKAGE.name.toLowerCase();
  const fileNamePrefix = `${PACKAGE.name.toLowerCase()}${ifProd() ? ".min" : ""}`;
  let found = false;
  let directory = __dirname;
  let devBuildDirectory = "public";
  while(ifProd() && found==0) {
    if(directory.endsWith(":\\")){
      found = true;
      directory = __dirname;
    } else if(directory.split(path.sep).pop() == "v1"){
      found = true;
      directory = path.resolve(directory, `./packages/${moduleName}`);
    } else {
      directory = path.resolve(directory, "..");
    }
  }
  return {
    cache: ifNotProd(),
    entry: ["@babel/polyfill", "./index.js"],
    resolve: {
      extensions: [".js"]
    },
    module: {
      rules: [{
          test: /\.(js|jsx)$/,
          loader: "babel-loader",
          options : {
            "presets": ["@babel/preset-env"]
          }
        },{
          test: /\.(css|less)$/,
          use: ["style-loader", "css-loader", "less-loader"]
        }
      ]
    },
    output : ifProd()
      ? {
        clean: {
          keep(asset) {
            return asset.includes(`bundle.${fileNamePrefix}.js`);
          },
          //dry: true, // Log the assets that should be removed instead of deleting them.
        },
        path : directory,
        filename : `bundle.${fileNamePrefix}.js?v=[contenthash]`,
        publicPath : `./packages/${moduleName}/`,
        chunkFilename : `bundle.[contenthash].min.js`
      } : {
        clean: {
          keep(asset) {
            return asset.includes(`bundle.${fileNamePrefix}.js`);
          },
          //dry: true, // Log the assets that should be removed instead of deleting them.
        },
        path : `${directory}/${devBuildDirectory}`,
        filename : `bundle.${fileNamePrefix}.js?v=[contenthash]`,
        publicPath : `./views/${moduleName}/src/${devBuildDirectory}/`,
        chunkFilename : `bundle.[contenthash].js`
      },
    optimization : {
      moduleIds : 'natural',
      chunkIds : 'natural'
    },
    plugins: [
      new webpack.ProvidePlugin({
        React: "react",
        Promise: "es6-promise"
      }),
    ]
  }
}