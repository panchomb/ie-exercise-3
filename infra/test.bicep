param adminCredentialsKeyVaultResourceId string = resourceId('Microsoft.KeyVault/vaults', 'panchomb-kv')
@secure()
param adminCredentialsKeyVaultSecretUserName string
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string


resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: adminCredentialsKeyVaultResourceId
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(adminCredentialsKeyVaultSecretUserName)) {
  name: !empty(adminCredentialsKeyVaultSecretUserName) ? adminCredentialsKeyVaultSecretUserName : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
   value: 'username'
  } 
}

resource secretAdminPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: !empty(adminCredentialsKeyVaultSecretUserPassword1) ? adminCredentialsKeyVaultSecretUserPassword1 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
   value: 'password1'
  }
}

resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: !empty(adminCredentialsKeyVaultSecretUserPassword2) ? adminCredentialsKeyVaultSecretUserPassword2 : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
   value: 'password2'
  }
}
