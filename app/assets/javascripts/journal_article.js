function ElementCtrl($scope) {
  $scope.isRemovable = function() {
    return $scope.eles.length > 1;
  };

  $scope.add = function() {
    $scope.eles.push({});
  };

  $scope.remove = function(index) {
    $scope.eles.splice(index, 1);
  };
}
