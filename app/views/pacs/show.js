function FindProxyForURL(url, host) {
	if (isInNet(host, "open.qyer.com"))    {
     return "PROXY <%= @pac.host %>:<%= @pac.port %>";
  }
	return "PROXY <%= @pac.host %>:<%= @pac.port %>; DIRECT";
}