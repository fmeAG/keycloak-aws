var res="";
var forEach = Array.prototype.forEach;
forEach.call(user.getGroupsStream().toArray(), function (group) {
  res=res+"-"+group.getName();
});
res=res+"-";
token.setOtherClaims("sub",res);
