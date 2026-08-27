const appName = document.querySelector('#app-name')
const appVersion = document.querySelector('#app-version')
const appPlatform = document.querySelector('#app-platform')

const loadAppInfo = async () => {
  const info = await window.electronAPI.getAppInfo()

  appName.textContent = info.name
  appVersion.textContent = info.version
  appPlatform.textContent = info.platform
  document.title = info.name
}

loadAppInfo().catch(() => {
  appVersion.textContent = 'Unavailable'
  appPlatform.textContent = 'Unavailable'
})
