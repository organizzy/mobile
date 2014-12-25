angular.module 'organizzy', ['ionic', 'organizzy.controllers']

.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    #if window.StatusBar
      # org.apache.cordova.statusbar required
      #StatusBar.styleDefault()

.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider

  .state 'login', {
    url: '/login'
    templateUrl: "templates/user/login.html"
    controller: 'UserLoginCtrl'
  }

  .state 'register', {
    url: '/register'
    templateUrl: "templates/user/register.html"
    controller: 'UserRegisterCtrl'
  }

  .state 'app', {
    templateUrl: "templates/main.html"
    controller: 'AppCtrl'
  }

  .state 'app.activity', {
    views:
      content :
        templateUrl: "templates/activity/index.html"
  }

  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise('/login');
