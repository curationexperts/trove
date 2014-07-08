#Tufts Digital Image Library

##Initial Setup for Developers

### Add secrets to your secrets file

```bash
cp config/secrets.yml.sample config/secrets.yml
```

* Edit config/secrets.yml
  * Add the fedora password
  * Replace the ```secret_key_base``` with a new key, which you can generate with ```rake secret```

### Specify your featured pids

```bash
cp config/feature_data.yml.sample config/feature_data.yml
```
