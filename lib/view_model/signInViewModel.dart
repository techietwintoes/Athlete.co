import 'package:attt/interface/signinInterface.dart';
import 'package:attt/view/chooseAthlete/pages/chooseAthlete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInViewModel implements SignInInterface {
  FirebaseUser _currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// twitter sign in classes
  TwitterLoginResult _twitterLoginResult;
  TwitterLoginStatus _twitterLoginStatus;
  TwitterSession _currentUserTwitterSession;

  /// sign in with twitter
  @override
  signInWithTwitter(BuildContext context) async {
    /// waiting for keys
    final TwitterLogin twitterLogin =
        new TwitterLogin(consumerKey: '', consumerSecret: '');

    _twitterLoginResult = await twitterLogin.authorize();
    _currentUserTwitterSession = _twitterLoginResult.session;
    _twitterLoginStatus = _twitterLoginResult.status;

    switch (_twitterLoginStatus) {
      case TwitterLoginStatus.loggedIn:
        _currentUserTwitterSession = _twitterLoginResult.session;
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ChooseAthlete()));
        break;

      case TwitterLoginStatus.cancelledByUser:
        print('Sign in cancelled by user.');
        break;

      case TwitterLoginStatus.error:
        print('An error occurred signing with Twitter.');
        break;
    }

    AuthCredential _authCredential = TwitterAuthProvider.getCredential(
        authToken: _currentUserTwitterSession?.token ?? '',
        authTokenSecret: _currentUserTwitterSession?.secret ?? '');
    AuthResult result =
        await _firebaseAuth.signInWithCredential(_authCredential);
    _currentUser = result.user;
  }

  /// sign in with google
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Future<String> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  /// google sign out
  @override
  signOutGoogle(BuildContext context) async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }
}
