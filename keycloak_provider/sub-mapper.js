var res="";
var forEach = Array.prototype.forEach;
forEach.call(user.getGroupsStream().toArray(), function (group) {
  res=res+"-"+group.getName();
});
res=res+"-";
exports=res;
