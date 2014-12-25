angular.module 'organizzy.controllers.user', []

.controller 'UserLoginCtrl', ($scope) ->
  $scope.form = {}

  $scope.submit = ->
    console.log $scope.loginForm
    console.log $scope.data


.controller 'UserRegisterCtrl', ($scope, $state) ->
  $scope.data = {}

  $scope.submit = ->
    console.log $scope.data
    console.log $scope.form
