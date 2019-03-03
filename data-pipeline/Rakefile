namespace :deploy do

  task :development do
    system 'rm -Rf vendor'
    if system 'bundle install --deployment --without test development'
      system 'sls deploy --stage development'
      system 'bundle install --quiet --no-deployment --with test development'
    end
  end

  task :test do
    system 'rm -Rf vendor'
    if system 'bundle install --deployment --without test development'
      system 'sls deploy --stage test'
      system 'bundle install --quiet --no-deployment --with test development'
    end
  end

  task :production do
    system 'rm -Rf vendor'
    if system 'bundle install --deployment --without test development'
      system 'sls deploy --stage production'
      system 'bundle install --quiet --no-deployment --with test development'
    end
  end
end
