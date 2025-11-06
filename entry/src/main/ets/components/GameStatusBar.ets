@Component
export struct GameStatusBar {
  @Prop score: number;
  @Prop best: number;
  @Prop lives: number;

  build() {
    Row({ space: 12 }) {
      Text(`Score: ${this.score}`).fontSize(12)
      Text(`Best: ${this.best}`).fontSize(12)
      Text(`❤ ${this.lives}`).fontSize(12)
    }
  }
}
