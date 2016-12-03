import Reflux from 'reflux';
let AuthActions = Reflux.createActions({
   // asyncResult creates 2 extra actions, one for success and one for failure
  'loginRequest': { asyncResult: true },
  'logout': { }
});
export default AuthActions;
