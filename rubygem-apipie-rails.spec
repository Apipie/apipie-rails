%global gemname apipie-rails

%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%if 0%{?rhel} == 6 || 0%{?fedora} < 17
%define rubyabi 1.8
%else
%define rubyabi 1.9
%endif

Summary: Rails API documentation tool and client generator.
Name: rubygem-%{gemname}
Version: 0.0.7
Release: 2%{?dist}
Group: Development/Libraries
License: MIT
URL: http://github.com/Pajk/apipie-rails
Source0: http://rubygems.org/downloads/%{gemname}-%{version}.gem
Requires: ruby(abi) >= %{rubyabi}
Requires: rubygems 
BuildRequires: ruby(abi) >= %{rubyabi}
BuildRequires: rubygems-devel
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
This gem adds new methods to Rails controllers that can be used to describe
resources exposed by API. Informations entered with provided DSL are used
to generate documentation, client or to validate incoming requests.

%prep
%setup -q -c -T
mkdir -p .%{gemdir}
gem install --local --install-dir .%{gemdir} \
            --force %{SOURCE0}

%build

%install
mkdir -p %{buildroot}%{gemdir}
cp -a .%{gemdir}/* \
        %{buildroot}%{gemdir}/


%files
%{geminstdir}/
%exclude %{gemdir}/cache/%{gemname}-%{version}.gem
%exclude %{geminstdir}/spec
%exclude %{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/specifications/%{gemname}-%{version}.gemspec
%doc %{geminstdir}/MIT-LICENSE
%doc %{geminstdir}/README.rdoc

%changelog
* Thu Jul 26 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.7-2
- removed doc files from rpm

* Wed Jul 25 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.7-1
- new package built with tito

