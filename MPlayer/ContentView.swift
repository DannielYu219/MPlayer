import SwiftUI
import AVFoundation
internal import Combine

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var songs: [URL] = []
    @State private var currentSongIndex = 0
    @State private var isRepeating = false
    @State private var showSettingView = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.black)
            VStack {
                // 专辑封面区域
                
                Spacer()
                ZStack{
                    HStack{
                        Spacer()
                        VStack{
                            /*Button(action: {
                                showSettingView.toggle()
                            }){
                                Image(systemName: "gearshape.2.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding(.all,10)
                            }
                            .padding(.all,20)
                            Spacer()*/
                        }
                    }
                    VStack{
                        ZStack {
                            if let player = audioPlayer, let artwork = getArtwork(from: player) {
                                Image(nsImage: artwork)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 400, height: 400)
                            } else {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 256, height: 256)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 400, height: 400)
                        .cornerRadius(20)
                        
                        // 当前播放曲目名称
                        Text(currentSongName)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                    HStack{
                        // 播放列表
                        List {
                            ForEach(Array(songs.enumerated()), id: \.element) { index, url in
                                Button(action:{
                                    setsong(at: index)
                                }){
                                    ZStack{
                                        if index == currentSongIndex{
                                            Rectangle()
                                                .fill(.clear)
                                                .opacity(0)
                                                .frame(width: .infinity, height: 40)
                                                .cornerRadius(20)
                                                .glassEffect(.regular.tint(.blue.opacity(0.33)))
                                        }
                                        HStack {
                                            Text(url.lastPathComponent)
                                                .foregroundColor(Color.white)
                                                .font(.title2)
                                            Spacer()
                                            Button(action:{
                                                if isPlaying{
                                                    audioPlayer?.pause()
                                                    setsong(at: index)
                                                    audioPlayer?.play()
                                                }else{
                                                    setsong(at: index)
                                                    audioPlayer?.play()
                                                }
                                            }){
                                                Image(systemName: "play.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                            }
                                            
                                        }
                                        .frame(height: 40)
                                        .padding(.horizontal, 10)
                                    }
                                }
                                .padding(.vertical, 3)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listStyle(.sidebar)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.never)
                        .frame(width: 400, height: .infinity)
                        .padding(.all, 20)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // 进度条
                VStack {
                    ZStack{
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 16)
                            .clipped()
                            .mask { RoundedRectangle(cornerRadius: 8, style: .continuous) }
                            .glassEffect(.regular)
                        Slider(value: $currentTime, in: 0...duration, onEditingChanged: sliderEditingChanged)
                            .accentColor(.white)
                            .frame(width: .infinity)
                            .padding(.horizontal, 4)
                    }
                    
                    HStack {
                        Text(timeString(time: currentTime))
                            .foregroundColor(.white)
                        Spacer()
                        Text(timeString(time: duration))
                            .foregroundColor(.white)
                    }
                    .frame(width: .infinity)
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 200)
                
                // 控制按钮
                HStack() {
                    // 导入按钮
                    Spacer()
                    Button(action: importSongs) {
                        ZStack{
                            Rectangle()
                                .fill(.clear)
                                .background(Material.ultraThin)
                                .frame(width: 64, height: 64)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 32, style: .continuous) }
                            Image(systemName: "folder")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .glassEffect(.regular)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    // 上一首
                    Button(action: previousSong) {
                        ZStack{
                            Rectangle()
                                .fill(.clear)
                                .background(Material.ultraThin)
                                .frame(width: 64, height: 64)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 32, style: .continuous) }
                            Image(systemName: "backward.end.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .glassEffect(.regular)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    // 暂停/播放
                    Button(action: togglePlayPause) {
                        ZStack{
                            Rectangle()
                                .fill(.clear)
                                .background(Material.ultraThin)
                                .frame(width: 64, height: 64)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 32, style: .continuous) }
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .glassEffect(.regular)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    // 下一首
                    Button(action: nextSong) {
                        ZStack{
                            Rectangle()
                                .fill(.clear)
                                .background(Material.ultraThin)
                                .frame(width: 64, height: 64)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 32, style: .continuous) }
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .glassEffect(.regular)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    // 重播
                    Button(action: toggleRepeat) {
                        ZStack{
                            Rectangle()
                                .fill(.clear)
                                .background(Material.ultraThin)
                                .frame(width: 64, height: 64)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 32, style: .continuous) }
                            Image(systemName: "repeat")
                                .font(.system(size: 24))
                                .foregroundColor(isRepeating ? .blue : .white)
                        }
                        .glassEffect(.regular)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .frame(width: .infinity, height: .infinity)
            .background{
                ZStack{
                    Rectangle()
                        .fill(Color.black)
                    if colorScheme == .light{
                        Image("BG2")
                            .resizable()
                            .scaledToFill()
                            .mask(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.gray, .clear]), // 黑色到透明
                                                startPoint: .center,
                                                endPoint: .bottom
                                            )
                                        )
                    }else{
                        Image("BG2D")
                            .resizable()
                            .scaledToFill()
                            .mask(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.gray, .clear]), // 黑色到透明
                                                startPoint: .center,
                                                endPoint: .bottom
                                            )
                                        )
                    }
                }
            }
            .cornerRadius(8)
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showSettingView) {
            SettingView()
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
        .onAppear {
            setupKeyboardListeners()
        }
        .ignoresSafeArea(.all)
    }
    
    // 从音频文件获取封面
    
    // 添加键盘事件监听器
    private func setupKeyboardListeners() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            var modifiers = event.modifierFlags
            if event.keyCode == 49 { // 空格键
                togglePlayPause()
                return nil
            }
            if event.keyCode == 31 && modifiers.contains(.command) {
                importSongs()
                return nil
            }
            
            // 媒体控制键 (F7, F8, F9)
            switch event.keyCode {
            case 103: // 上一首 (F7)
                previousSong()
                return nil
            case 107: // 播放/暂停 (F8)
                togglePlayPause()
                return nil
            case 105: // 下一首 (F9)
                nextSong()
                return nil
            default:
                return event
            }
        }
    }
    
    private var currentSongName: String {
        guard currentSongIndex >= 0 && currentSongIndex < songs.count else {
            return "未选择歌曲"
        }
        return songs[currentSongIndex].lastPathComponent
    }
    
    private func getArtwork(from player: AVAudioPlayer) -> NSImage? {
        guard let url = player.url else { return nil }
        
        let asset = AVAsset(url: url)
        let metadata = asset.metadata
        
        for item in metadata {
            if item.commonKey == .commonKeyArtwork,
               let data = item.value as? Data,
               let image = NSImage(data: data) {
                return image
            }
        }
        
        return nil
    }
    
    // 导入歌曲
    private func importSongs() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.audio]
        
        if panel.runModal() == .OK {
            songs = panel.urls
            if !songs.isEmpty {
                currentSongIndex = 0
                loadSong(at: currentSongIndex)
            }
        }
    }
    
    // 加载歌曲
    private func loadSong(at index: Int) {
        guard index >= 0 && index < songs.count else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: songs[index])
            audioPlayer?.delegate = PlayerDelegate(
                didFinishPlaying: { [self] successfully in
                    if isRepeating {
                        audioPlayer?.currentTime = 0
                        audioPlayer?.play()
                    } else {
                        nextSong()
                    }
                }
            )
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            
            if isPlaying {
                audioPlayer?.play()
            }
        } catch {
            print("Failed to load song: \(error)")
        }
    }
    
    // 切换播放/暂停
    private func togglePlayPause() {
        guard audioPlayer != nil else { return }
        
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        
        isPlaying.toggle()
    }
    
    // 下一首
    private func nextSong() {
        guard !songs.isEmpty else { return }
        
        currentSongIndex = (currentSongIndex + 1) % songs.count
        loadSong(at: currentSongIndex)
        if isPlaying {
            audioPlayer?.play()
        }
    }
    
    //指定播放
    private func setsong(at selected: Int) {
        guard !songs.isEmpty else { return }
        
        currentSongIndex = selected % songs.count
        loadSong(at: currentSongIndex)
    }
    
    // 上一首
    private func previousSong() {
        guard !songs.isEmpty else { return }
        
        currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
        loadSong(at: currentSongIndex)
        if isPlaying {
            audioPlayer?.play()
        }
    }
    
    // 切换重播
    private func toggleRepeat() {
        isRepeating.toggle()
    }
    
    // 更新进度
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        
        if !player.isPlaying {
            return
        }
        
        currentTime = player.currentTime
        duration = player.duration
    }
    
    // 进度条拖动处理
    private func sliderEditingChanged(editingStarted: Bool) {
        if !editingStarted {
            audioPlayer?.currentTime = currentTime
        }
    }
    
    // 时间格式化
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }
}

// 自定义AVAudioPlayerDelegate实现
class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let didFinishPlaying: (Bool) -> Void
    
    init(didFinishPlaying: @escaping (Bool) -> Void) {
        self.didFinishPlaying = didFinishPlaying
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinishPlaying(flag)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
