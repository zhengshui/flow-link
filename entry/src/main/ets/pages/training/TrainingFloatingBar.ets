/**
 * 训练悬浮bar组件
 * 训练最小化后显示在全局页面右下角
 * 独立计时，不依赖训练页面的计时器
 */

@Component
export struct TrainingFloatingBar {
  @StorageLink('trainingTime') trainingTime: string = '00:00';
  @StorageLink('trainingIsRunning') trainingIsRunning: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('trainingStartTime') trainingStartTime: number = 0;
  @StorageProp('trainingPausedTime') trainingPausedTime: number = 0;
  @StorageProp('trainingPauseStartTime') trainingPauseStartTime: number = 0;
  @State timerInterval: number = -1;
  onExpand: () => void = (): void => {};

  aboutToAppear(): void {
    // 启动独立计时器
    this.startTimer();
  }

  aboutToDisappear(): void {
    // 停止计时器
    this.stopTimer();
  }

  startTimer(): void {
    this.stopTimer();
    // 立即更新一次
    this.updateTimer();
    // 每秒更新
    this.timerInterval = setInterval((): void => {
      this.updateTimer();
    }, 1000);
  }

  stopTimer(): void {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }

  updateTimer(): void {
    if (this.trainingStartTime <= 0) {
      return;
    }

    // 计算已经过的时间（毫秒）
    let elapsed: number = Date.now() - this.trainingStartTime;

    // 减去已暂停的时间
    elapsed -= this.trainingPausedTime;

    // 如果当前是暂停状态，减去当前暂停的时间
    if (!this.trainingIsRunning && this.trainingPauseStartTime > 0) {
      elapsed -= (Date.now() - this.trainingPauseStartTime);
    }

    const totalSeconds: number = Math.max(0, Math.floor(elapsed / 1000));
    const hours: number = Math.floor(totalSeconds / 3600);
    const minutes: number = Math.floor((totalSeconds % 3600) / 60);
    const secs: number = totalSeconds % 60;

    const hoursStr: string = hours < 10 ? '0' + hours.toString() : hours.toString();
    const minutesStr: string = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
    const secsStr: string = secs < 10 ? '0' + secs.toString() : secs.toString();

    // 更新显示时间
    if (hours > 0) {
      this.trainingTime = hoursStr + ':' + minutesStr + ':' + secsStr;
    } else {
      this.trainingTime = minutesStr + ':' + secsStr;
    }
  }

  build() {
    Row({ space: 10 }) {
      // 运行状态指示点（带呼吸动画效果）
      Circle()
        .width(8)
        .height(8)
        .fill(this.trainingIsRunning ? $r('app.color.color_success') : $r('app.color.color_warning'))

      // 训练信息
      Column({ space: 2 }) {
        Text('训练中')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
        Text(this.trainingTime)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .alignItems(HorizontalAlign.Start)

      // 展开图标
      SymbolGlyph($r('sys.symbol.chevron_up'))
        .fontSize(16)
        .fontColor([$r('app.color.brand_primary')])
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(24)
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.12)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({
      right: 16,
      bottom: 80 + this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .onClick((): void => { this.onExpand(); })
    .animation({ duration: 200, curve: Curve.EaseOut })
  }
}


