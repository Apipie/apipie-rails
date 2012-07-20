%define gem_name apipie-rails
Name: rubygem-%{gem_name}
Version: 0.0.6
Release: 1%{?dist}
Summary: Rails API documentation tool and client generator.

Group: Development/Libraries
License: MIT
URL: https://github.com/Pajk/apipie-rails
Source0: http://rubygems.org/downloads/%{gem_name}-%{version}.gem

BuildRequires: rubygems rubygems-devel
Requires: rubygems
%if 0%{?rhel} == 6 || 0%{?fedora} < 17
Requires: ruby(abi) = 1.8
%else
Requires: ruby(abi) >= 1.9
%endif
Provides: rubygem(%{gem_name}) = %{version}
BuildArch: noarch

%description

%prep
gem unpack %{SOURCE0}
%setup -q -D -T -n %{gem_name}-%{version}
gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec


%build
mkdir -p .%{gem_dir}

# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

export CONFIGURE_ARGS="--with-cflags='%{optflags}'"
# gem install compiles any C extensions and installs into a directory
# We set that to be a local directory so that we can move it into the
# buildroot in %%install
gem install -V \
        --local \
        --install-dir ./%{gem_dir} \
        --bindir ./%{_bindir} \
        --force \
        --rdoc \
        %{gem_name}-%{version}.gem

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a ./%{gem_dir}/* %{buildroot}%{gem_dir}/

%files
%{gem_dir}/gems/%{gem_name}-%{version}/


%doc MIT-LICENSE README.rdoc

%{gem_dir}/cache/%{gem_name}-%{version}.gem
%{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%{gem_docdir}

%changelog

