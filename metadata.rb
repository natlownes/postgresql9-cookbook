maintainer       "Fort Hill Company"
maintainer_email "dev@forthillcompany.com"
license          "Apache 2.0"
description      "Installs/Configures postgresql9"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

deps = %(apt)
deps.each do |d|
  depends d
end
