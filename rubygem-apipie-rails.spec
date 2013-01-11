%global gem_name apipie-rails

%if 0%{?rhel} == 6 || 0%{?fedora} < 17
%define rubyabi 1.8
%else
%define rubyabi 1.9.1
%endif
%if 0%{?rhel} == 6
%global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}
%global gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%global gem_libdir %{gem_dir}/gems/%{gem_name}-%{version}/lib
%endif

Summary: Rails API documentation tool and client generator
Name: rubygem-%{gem_name}
Version: 0.0.11
Release: 3%{?dist}
Group: Development/Libraries
License: MIT
URL: http://github.com/Pajk/apipie-rails
Source0: http://rubygems.org/downloads/%{gem_name}-%{version}.gem
Requires: ruby(abi) >= %{rubyabi}
Requires: rubygems
%if 0%{?fedora}
BuildRequires: rubygems-devel
%endif
BuildRequires: ruby(abi) >= %{rubyabi}
BuildRequires: rubygems
BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}

%description
This gem adds new methods to Rails controllers that can be used to describe
resources exposed by API. Information entered with provided DSL are used
to generate documentation, client or to validate incoming requests.

%package doc
BuildArch:  noarch
Requires:   %{name} = %{version}-%{release}
Summary:    Documentation for rubygem-%{gem_name}

%description doc
This package contains documentation for rubygem-%{gem_name}.

%prep
%setup -q -c -T
mkdir -p .%{gem_dir}
gem install --local --install-dir .%{gem_dir} \
            --force %{SOURCE0} --no-rdoc --no-ri

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

%files
%dir %{gem_instdir}
%{gem_instdir}/app
%{gem_instdir}/lib
%exclude %{gem_instdir}/Gemfile.lock
%exclude %{gem_cache}
%{gem_spec}
%doc %{gem_instdir}/MIT-LICENSE
%doc %{gem_instdir}/APACHE-LICENSE-2.0

%exclude %{gem_instdir}/spec
%exclude %{gem_instdir}/rel-eng
%exclude %{gem_instdir}/.gitignore
%exclude %{gem_instdir}/.rspec
%exclude %{gem_instdir}/.rvmrc
%exclude %{gem_instdir}/.travis.yml
%exclude %{gem_instdir}/rubygem-apipie-rails.spec
%exclude %{gem_dir}/cache/%{gem_name}-%{version}.gem

%files doc
%doc %{gem_instdir}/MIT-LICENSE
%doc %{gem_instdir}/README.rdoc
%doc %{gem_instdir}/NOTICE
%{gem_instdir}/Rakefile
%{gem_instdir}/Gemfile
%{gem_instdir}/%{gem_name}.gemspec

%changelog
* Fri Sep 07 2012 Miroslav Suchý <msuchy@redhat.com> 0.0.11-3
- summary should not end with dot (msuchy@redhat.com)
- fix spelling (msuchy@redhat.com)
- do not package Gemfile.lock (msuchy@redhat.com)

* Fri Aug 17 2012 Ivan Necas <inecas@redhat.com> 0.0.11-2
- fix building for F17 reusing the macros from rubygem- devel

* Wed Aug 15 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.11-1
- apipie-rails v0.0.11
- cli client improvements

* Tue Jul 31 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.9-2
- exclude documentation from rpm

* Tue Jul 31 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.9-1
- New version of apipie-rails gem (pajkycz@gmail.com)
- fixed client generator
- resource level error descriptions
- response supported formats

* Thu Jul 26 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.8-3
- Require rubygems in spec file

* Thu Jul 26 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.8-2
- New version of apipie-rails gem
- Generated client improvements

* Thu Jul 26 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.7-2
- removed doc files from rpm

* Wed Jul 25 2012 Pavel Pokorný <pajkycz@gmail.com> 0.0.7-1
- new package built with tito

