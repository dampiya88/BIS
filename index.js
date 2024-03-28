import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import AppRoutes from './routes';
import store from './store';
import NotificationPrompt from "./components/common/NotificationPrompt";
import Notification from './components/common/Notifications'

ReactDOM.render(
  <Provider store = {store}>
    <NotificationPrompt />
    <Notification />
    <AppRoutes />
  </Provider>
  ,
  document.getElementById('reactRoot')
);

stopWaiting();

