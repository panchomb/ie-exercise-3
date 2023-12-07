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

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = if (!empty(adminCredentialsKeyVaultSecretUserName)) {
  name: '${adminCredentialsKeyVault.name}/${!empty(adminCredentialsKeyVaultSecretUserName) ? adminCredentialsKeyVaultSecretUserName : 'dummySecret'}'
  properties: {
    value: 'username'
  }
}

resource secretAdminPassword1 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${adminCredentialsKeyVault.name}/${!empty(adminCredentialsKeyVaultSecretUserPassword1) ? adminCredentialsKeyVaultSecretUserPassword1 : 'dummySecret'}'
  properties: {
    value: 'password1'
  }
}

resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${adminCredentialsKeyVault.name}/${!empty(adminCredentialsKeyVaultSecretUserPassword2) ? adminCredentialsKeyVaultSecretUserPassword2 : 'dummySecret'}'
  properties: {
    value: 'password2'
  }
}
