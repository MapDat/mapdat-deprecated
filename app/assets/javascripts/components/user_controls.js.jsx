import React from 'react';
import SessionStore from './session_store.js';
import AuthActions from './auth_actions.js';

let UserControls = React.createClass({
  handleLogout(e) {
    e.preventDefault();
    AuthActions.logout();
  },
  render() {
    if (SessionStore.isLoggedIn()) {
      return (
        <div className='UserControls'>
          <span>{SessionStore.getUsername}</span>
          <a href='#' onClick={this.handleLogout}>Logout</a>
        </div>
      );
    } else {
      return (
        <div className='UserControls'>
          <a href='#/login'>Login</a>
        </div>
      );
    }
  }
});

export default UserControls;
