//
//  WriteContentViewController.swift
//  may24
//
//  Created by 최병욱 on 6/1/24.
//

import UIKit
import AVFAudio

class WriteContentViewController:UIViewController,EmotionDelegate_1{
    
    private let ar = AudioRecorder()
    private var player :AVAudioPlayer?

    func EVC_To_WCVC_Type(type: String) {
        self.EmotionTypeLabel.text = type
        if(type == "중립"){
            self.HideView.isHidden = false
        }
        else{
            self.HideView.isHidden = true
        }
    }
    
    func EVC_TO_WCVC_Level(level: String) {
        self.EmotionLevelLabel.text = level
    }
    
    
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBOutlet weak var CircleView: UIView!
    
    @IBOutlet weak var ContentTextField: UITextView!
    
    @IBOutlet weak var TagTextField: UITextField!
    
    @IBOutlet weak var DualView: UIView!
    @IBOutlet weak var DualLabel: UILabel!
    @IBOutlet weak var EmotionButton: UIButton!
    @IBOutlet weak var EditButton: UIButton!
    
    
    @IBOutlet weak var EmotionView: UIView!
    
    @IBOutlet weak var EmotionTypeLabel: UILabel!
    @IBOutlet weak var EmotionLevelLabel: UILabel!
    
    @IBOutlet weak var HideView: UIView!
    
    
    
    @IBOutlet weak var VoiceView_1: UIView!
    @IBOutlet weak var VoiceView_2: UIView!
    @IBOutlet weak var VoiceView_3: UIView!
    
    @IBOutlet weak var VoiceLabel_1: UILabel!
    @IBOutlet weak var VoiceLabel_2: UILabel!
    @IBOutlet weak var VoiceLabel_3: UILabel!
    
    
    
    @IBOutlet weak var RecordImage: UIImageView!
    
    @IBOutlet weak var DoneView: UIView!
    
    var BookId:Int = 0
    var PageTitle:String = ""
    var defaultVoice:String = ""
    var scrapVoiceList : [VoiceResponseDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        
        RecordImage.image = UIImage(named: "microphone.png")
        
        CircleView.layer.cornerRadius = 35
        CircleView.layer.borderColor = UIColor.black.cgColor
        CircleView.layer.borderWidth = 2
        
        ContentTextField.text = "이곳에 내용을 입력하세요."
        let attrString = NSMutableAttributedString(string: ContentTextField.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 20
        paragraphStyle.alignment = .natural
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        ContentTextField.attributedText = attrString
        ContentTextField.font = UIFont(name: "BMHANNAAirOTF", size: 20)
        
        EditButton.isHidden = true
        EmotionView.isHidden = true
        
        DualView.layer.cornerRadius = 20
        DualView.layer.borderColor = UIColor.black.cgColor
        DualView.layer.borderWidth = 2
        
        
        DoneView.layer.cornerRadius = 20
        DoneView.layer.borderColor = UIColor.black.cgColor
        DoneView.layer.borderWidth = 2
        
        HideView.isHidden = true
        
        VoiceView_1.layer.cornerRadius = 20
        VoiceView_1.layer.borderWidth = 2
        VoiceView_1.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_1.isHidden = true
        
        VoiceView_2.layer.cornerRadius = 20
        VoiceView_2.layer.borderWidth = 2
        VoiceView_2.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_2.isHidden = true
        
        VoiceView_3.layer.cornerRadius = 20
        VoiceView_3.layer.borderWidth = 2
        VoiceView_3.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_3.isHidden = true
        
        VoiceLabel_1.textColor = UIColor.lightGray
        VoiceLabel_2.textColor = UIColor.lightGray
        VoiceLabel_3.textColor = UIColor.lightGray
        
        
        ar.requestAudioPermission()
    }
    
    
    @IBAction func STTButtonTapped(_ sender: UIButton) {
        
        
        if(RecordImage.image == UIImage(named: "microphone.png")){
            // 자신의 이미지를 pause 로 바꾸고
            RecordImage.image = UIImage(named: "pause.png")
            // 녹음 시작
            startRecord()
            
        }
        else{
            // 자신의 이미지를 microphone 으로 바꾸고
            RecordImage.image = UIImage(named: "microphone.png")
            // 녹음 중단
            stopRecord()
        }
    }
    
    
    
    private func startRecord() {
        ar.initRecorder(path: "temp.wav")
        ar.start()
    }
    
    private func stopRecord() {
        ar.stop()
        guard let data = ar.fetchData() else {
            print("error on fetch Data!")
            return
        }
        
        getSTTFrom(data: data)
    }
    
    
    private func getSTTFrom(data: Data) {
        let url = URL(string: "https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor")!
        let headers = [
            "Content-Type": "application/octet-stream",
            "X-NCP-APIGW-API-KEY-ID": "4k0u4eeqjb",
            "X-NCP-APIGW-API-KEY": "6UCOsnQ7DgDuPP7sGKNvNnYOfUusxbftQ3Pw1MUR"
        ]
        
        // 녹음을 해서 data에 넣어야 할듯.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data as Data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let dt = data {
                
                guard let str = String(data: dt, encoding: .utf8) else {
                    print("encoding string error")
                    return
                }
                if let jsonData = str.data(using: .utf8) {
                    do {
                        // JSON 데이터를 Dictionary로 변환
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            guard let text = jsonObject["text"] as? String else {
                                return
                            }
                            DispatchQueue.main.async {
                                self.ContentTextField.text = text
                            }
                        }
                    } catch {
                        print("Failed to convert JSON string to Dictionary: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to convert JSON string to Data")
                }
            }
        }
        task.resume()
    }
    
    
    @IBAction func EmotionButtonTapped(_ sender: UIButton) {
        guard let x = self.ContentTextField.text else {
            return
        }
        loadEmotionByContents(text: x)
        loadVoiceList()
    }
    
    private func showEmotionView(emotion: String, strength: String) {
        DispatchQueue.main.async {
            self.EmotionView.isHidden = false
            self.EditButton.isHidden = false
            self.EmotionButton.isHidden = true
            self.DualLabel.text = "직접 변경"
            self.EmotionTypeLabel.text = emotion
            self.EmotionLevelLabel.text = strength
            if(self.EmotionTypeLabel.text == "중립"){
                self.HideView.isHidden = false
            }
            
        }
    }
    
    
    @IBAction func EditButtonTapped(_ sender: UIButton) {
        guard let evc = self.storyboard?.instantiateViewController(identifier: "EmotionVC") as? EmotionViewController else {return}
        evc.emotionDelegate_1 = self
        
        if(EmotionTypeLabel.text == "행복"){
            evc.Type_num = 1
        }
        else if(EmotionTypeLabel.text == "슬픔"){
            evc.Type_num = 2
        }
        else if(EmotionTypeLabel.text == "화남"){
            evc.Type_num = 3
        }
        else{
            evc.Type_num = 4
        }
        
        
        if(EmotionLevelLabel.text == "낮음"){
            evc.Level_num = 1
        }
        else if(EmotionLevelLabel.text == "보통"){
            evc.Level_num = 2
        }
        else{
            evc.Level_num = 3
        }
        
        
        self.navigationController?.pushViewController(evc, animated: true)
    }
    
    
    @IBAction func VoiceTapped_1(_ sender: UIButton) {
        VoiceView_1.layer.borderColor = UIColor.black.cgColor
        VoiceView_2.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_3.layer.borderColor = UIColor.lightGray.cgColor
        
        VoiceLabel_1.textColor = UIColor.black
        VoiceLabel_2.textColor = UIColor.lightGray
        VoiceLabel_3.textColor = UIColor.lightGray
        
        guard let t = self.EmotionLevelLabel.text else {
            return
        }
        let st = switch  t {
        case "낮음":0
        case "보통":1
        case "높음":2
        default:0
        }
        
        defaultVoice = EmotionBasedDefaultVoices.extractFrom(emotion: self.EmotionTypeLabel.text!, strength: st).rawValue
    }
    
    
    
    @IBAction func VoiceTapped_2(_ sender: UIButton) {
        VoiceView_1.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_2.layer.borderColor = UIColor.black.cgColor
        VoiceView_3.layer.borderColor = UIColor.lightGray.cgColor
        
        VoiceLabel_1.textColor = UIColor.lightGray
        VoiceLabel_2.textColor = UIColor.black
        VoiceLabel_3.textColor = UIColor.lightGray
        
        defaultVoice = scrapVoiceList[0].userEmail
    }
    
    
    
    @IBAction func VoiceTapped_3(_ sender: UIButton) {
        VoiceView_1.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_2.layer.borderColor = UIColor.lightGray.cgColor
        VoiceView_3.layer.borderColor = UIColor.black.cgColor
        
        VoiceLabel_1.textColor = UIColor.lightGray
        VoiceLabel_2.textColor = UIColor.lightGray
        VoiceLabel_3.textColor = UIColor.black
        
        defaultVoice = scrapVoiceList[1].userEmail
    }
    
    @IBAction func PlayButtonTapped_1(_ sender: UIButton) {
        print("hello")
        playDefault()
    }
    
    
    @IBAction func PlayButtonTapped_2(_ sender: UIButton) {
        print("2")
        playVoiceTest(voiceId: scrapVoiceList[0].id)
    }
    
    @IBAction func PlayButtonTapped_3(_ sender: UIButton) {
        print("3")
        playVoiceTest(voiceId: scrapVoiceList[1].id)
    }
    
    
    
    @IBAction func DoneButtonTapped(_ sender: UIButton) {
        
        var TagArrTemp:[String.SubSequence] = TagTextField.text!.split(separator: ", ", omittingEmptySubsequences: true)
        var TagArr:[String] = []
        for i in TagArrTemp{
            TagArr.append(String(i.suffix(i.count - 1)))
        }
        
        
        var emo_type:String = ""
        if (EmotionTypeLabel.text == "화남") { emo_type = "ANGER" }
        if (EmotionTypeLabel.text == "슬픔") { emo_type = "SADNESS" }
        if (EmotionTypeLabel.text == "행복") { emo_type = "HAPPINESS" }
        if (EmotionTypeLabel.text == "중립") { emo_type = "NEUTRAL" }
        
        
        var emo_intensity:Int = 0
        if (EmotionLevelLabel.text == "낮음") { emo_intensity = 0 }
        if (EmotionLevelLabel.text == "보통") { emo_intensity = 1 }
        if (EmotionLevelLabel.text == "높음") { emo_intensity = 2 }
        
        var voiceUserMail = defaultVoice
        
        // 아래 api 에 defaultVoice 를 넣을 수 있게 수정 필요한것 같음
        PageApi.shared.savePage(bookId: BookId, content: ContentTextField.text!, emotionIntensity: emo_intensity, emotionType: emo_type, hashtags: TagArr, title: PageTitle){ res in
            switch res{
            case .success(let data):
                print(data)
                print("page saving success")
                PageApi.shared.updateDefaultVoiceByPage(pageId: data.pageId, email: voiceUserMail) { res in
                    switch res {
                    case .success(let succ):
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    private func loadEmotionByContents(text: String) {
        VoiceApi.shared.getEmotionFromContent(content: text) { res in
            switch res {
            case .success(let emotion):
                let strength = switch emotion.strength {
                case 0: "낮음"
                case 1: "보통"
                case 2: "높음"
                default: ""
                }
                self.showEmotionView(emotion: emotion.emotion, strength: strength)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadVoiceList() {
        VoiceApi.shared.getScrappedVoiceList { res in
            switch res  {
            case .success(let list):
                self.scrapVoiceList = list
                self.showVoiceList(scrapVoices: list)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showVoiceList(scrapVoices: [VoiceResponseDto]){
        
        DispatchQueue.main.async {
            self.VoiceView_1.isHidden = false
        
            
            for (i, voice) in scrapVoices.enumerated() {
                if (i == 0){
                    self.VoiceView_2.isHidden = false
                    self.VoiceLabel_2.text = voice.userNickname + " 님의 목소리"
                }
                if (i == 1){
                    self.VoiceView_3.isHidden = false
                    self.VoiceLabel_3.text = voice.userNickname + " 님의 목소리"
                }
            }
        }
        
    }
    private func playVoiceTest(voiceId:Int) {
        VoiceApi.shared.getAudibleTextData(
            emotion: "중립",
            content: self.ContentTextField.text ?? "입력 안됨",
            intensity: 0,
            voiceId: voiceId
        ) { res in
            switch res {
            case .failure(let error):
                print(error)
                //todo: error handle
                
            case .success(let data):
                self.playAudioData(data: data)
            }
            
        }
    }
    private func playAudioData(data: Data) {
        do {
            player = try AVAudioPlayer(data: data)
        } catch {
            print("error on AVplayer")
            return
        }
        
        // Try to create an AVAudioPlayer object from the data
        guard let audioPlayer = player else {
            // If creating the player fails, it's likely not audio data
            print("Error: Unable to create AVAudioPlayer from data")
            return
        }
        
        audioPlayer.volume = 0.5
        audioPlayer.play()
    }
    
    private func playDefault() {
        // CLOVA로 TTS
        var tts_speaker:String = "nara"
        var tts_text:String = "문장이 입력되지 않았습니다"
        var tts_volume:Int = 0
        var tts_speed:Int = 0
        var tts_pitch:Int = 0
        var tts_emotion: Int = 0
        let voice_name = defaultVoice
        var tts_emotion_strength = 0
        if(voice_name == "CLOVA_simple"){
            tts_speaker = "nara"
            tts_emotion = 0
        }
        if(voice_name == "CLOVA_sad_0"){
            tts_speaker = "ngoeun"
            tts_emotion = 1
            tts_emotion_strength = 0
        }
        if(voice_name == "CLOVA_sad_1"){
            tts_speaker = "ngoeun"
            tts_emotion = 1
            tts_emotion_strength = 1
        }
        if(voice_name == "CLOVA_sad_2"){
            tts_speaker = "ngoeun"
            tts_emotion = 1
            tts_emotion_strength = 2
        }
        if(voice_name == "CLOVA_happy_0"){
            tts_speaker = "ndonghyun"
            tts_emotion = 2
            tts_emotion_strength = 0
        }
        if(voice_name == "CLOVA_happy_1"){
            tts_speaker = "ndonghyun"
            tts_emotion = 2
            tts_emotion_strength = 1
        }
        if(voice_name == "CLOVA_happy_2"){
            tts_speaker = "ndonghyun"
            tts_emotion = 2
            tts_emotion_strength = 2
        }
        if(voice_name == "CLOVA_rage_0"){
            tts_speaker = "ndonghyun"
            tts_emotion = 3
            tts_emotion_strength = 0
        }
        if(voice_name == "CLOVA_rage_1"){
            tts_speaker = "ndonghyun"
            tts_emotion = 3
            tts_emotion_strength = 1
        }
        if(voice_name == "CLOVA_rage_2"){
            tts_speaker = "ndonghyun"
            tts_emotion = 3
            tts_emotion_strength = 2
        }
        
        
        let session = AVAudioSession.sharedInstance()
        
        try? session.setCategory(.playAndRecord, options: [.allowAirPlay,.allowBluetooth,.defaultToSpeaker])
        try? session.setActive(true)
        
        tts_text = self.ContentTextField.text!
        
        let data = NSMutableData(data: "speaker=\(tts_speaker)".data(using: .utf8)!)
        data.append("&text=\(tts_text)".data(using: .utf8)!)
        data.append("&volume=\(tts_volume)".data(using: .utf8)!)
        data.append("&speed=\(tts_speed)".data(using: .utf8)!)
        data.append("&pitch=\(tts_pitch)".data(using: .utf8)!)
        //data.append("&emotion=\(tts_emotion)".data(using: .utf8)!)
        //data.append("&emotion-strength=\(tts_emotion_strength)".data(using: .utf8)!)
        
        let url = URL(string: "https://naveropenapi.apigw.ntruss.com/tts-premium/v1/tts")!
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "X-NCP-APIGW-API-KEY-ID": "4k0u4eeqjb",
            "X-NCP-APIGW-API-KEY": "6UCOsnQ7DgDuPP7sGKNvNnYOfUusxbftQ3Pw1MUR"
        ]
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data as Data
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                self.player = try? AVAudioPlayer(data: data)
                self.player?.prepareToPlay()
                self.player?.play()
            }
        }
        
        task.resume()
    }
}

