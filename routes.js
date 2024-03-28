import "./containers/css/common.less";

import React, { useEffect } from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import queryString from 'query-string';
import Home from './containers/Home';

export default () => {
  return (
    <BrowserRouter>
      <Switch>
        <Route render={
          props => {
            const parsedUrl = queryString.parse(location.search);
            switch (parsedUrl.action.toLowerCase()) {
              case "reports.home":
                return <Home />;
              default:
                window.location = location.href;
                return null;
            }
          }
        } />
      </Switch>
    </BrowserRouter>
  );

};