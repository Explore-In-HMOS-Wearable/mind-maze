@Builder
export function TileButton(bg: Resource, flashing: boolean, onTap: () => void) {
  Button('')
    .width('100%')
    .height('100%')
    .backgroundColor(bg)
    .borderRadius(16)
    .onClick(() => {
      if (onTap) { void onTap(); }
    })
}
