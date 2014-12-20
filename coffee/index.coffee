
imageArray = [
]


#問題の初期値
word = 0
#背景画像を表示する領域の数
VIEWCOUNT = 19
#スクラッチの数
scratchCount = 25
#単語の数
quizCount = wordArray4.length - 1
#時間
TIME = 20
time = TIME
timer = 0
#残りのタッチ数
restTouch = 50
#消したパネルの数
clickCount = 0
clickLevel = 0
#得点の初期値
point = 0
#現在の問題数
stageCount = 0
#スクラッチボックスの再表示のスピード
REBIRTHTIME = 300
rebirthTime = REBIRTHTIME
#音量の初期値
volume = 1

#得点を加算する値の配列
bonusPoint = [
  1
  3
  6
  9
  12
  15
  18
  21
  24
  27
  30
]

#wordをスライスして１文字ずつにしたstringを入れる配列
sliceWordArray = []

#ランダムの数字を入れておく配列
numberArray = []

#sliceWordArrayの画像を入れておく配列
wordImagesArray = []

#解答ボタンに表示する文字を入れておく配列
answerArray = []

#記録の追加
newRecord = localStorage.getItem 'record'

recordStorage = () ->
  record = localStorage.getItem 'record'
  if point > record
    localStorage.setItem 'record', point
    newRecord = localStorage.getItem 'record'
    reportScore()

#記録の書き換え
addRecord = ->
  $('#record .count').text """#{newRecord} pt""" if newRecord

################　　問題を作成する関数　　#################

#問題の文字をランダムで選択する
selectString = (array) ->
  random = _.random quizCount
  word = array[random][0]


#重複した数字があるかを確認する関数
isExistNumber = (array, value) ->
  _.include array, value


#ランダムの数字を作り、配列に代入する関数
randomNumber = (array) ->
  random = _.random VIEWCOUNT
  if(!isExistNumber array, random)
    array.push random
  else
    randomNumber numberArray


#問題の文字を分割する
sliceString = (word) ->
  for i in [0...word.length]
    sliceWordArray.push word.slice i, i+1


#sliceWordArrayの文字に対応した画像を表示する。
takeImage = (array) ->
  for key of array
    string = array[key][0]
    randomNumber numberArray
    if stageCount <= 10
      $('#back_image div').eq(numberArray[key]).removeClass().addClass """sprite-lower_#{string}"""
    else
      randomString = _.random 1
      $('#back_image div').eq(numberArray[key]).removeClass().addClass """sprite-capital_#{string}"""  if randomString == 0
      $('#back_image div').eq(numberArray[key]).removeClass().addClass """sprite-lower_#{string}"""  if randomString == 1

#scratchに表示する画像をランダムで生じする関数
takeScratchImage = () ->
  random = _.random 0, 7
  $('#scratch div').css 'background-image', """url(#{scratchImageAraay[random]})"""


##############  解答を作成する関数  #################

#パターンにマッチした解答を選択する関数
selectMatch = () ->
  matchArray = wordArray4
  for i in [0...wordArray4.length]
    matchArray[i][1] = 0
  for key1 of sliceWordArray
    for key2 of matchArray
      getMatch = matchArray[key2][0].indexOf sliceWordArray[key1]
      matchArray[key2][1]++  if getMatch >= 0
  rejectArray = rejectMatch matchArray   #パターンが全く同じ物を配列から取り除く
  sortMatch rejectArray                  #マッチした文字が多い順になるようにソートする
  sliceArray = rejectArray.slice 0, 11   #ソートした配列から上位12つを取り出す
  shuffleArray = _.shuffle sliceArray    #取り出したものをシャッフルする
  answerArray = shuffleArray.slice 0, 5  #シャッフルしたものから解答のボタンに反映するものを５つ取り出す


#パターンが全く同じ物を配列から取り除く関数
rejectMatch = (array)->
  _.reject array, (num)->
    num[1] >= word.length

#マッチした文字が多い順になるようにソートする関数
sortMatch = (array) ->
  array.sort((a,b) ->
    b[1] - a[1]
  )

#解答ボタンに表示する単語を完成させ、シャッフルする関数
createAnswer = () ->
  answerArray.push [word, 0]


#ボタンに解答を表示する関数
showAnswer = (array) ->
  viewAnswer = _.shuffle array
  for i in [0..5]
    $('#select div').eq(i).text("""#{viewAnswer[i][0]}""")


###########  ゲームの機能を実装 ############

#カウントダウンの関数
countStart = () ->
  timer = setInterval countDown, 1000

countDown = () ->
  time--
  if time <= 5
    $('#timer .count').css('color', 'red').text time
  else
    $('#timer .count').css('color', 'white').text time
  if time <1
    restTouch -= 1
    $('#rest .count').text restTouch
    $('#rest #change').text('-1').css('color', 'red').animate(opacity: 1, queue : false, 'fast').animate opacity: 0, 'slow'
    time = TIME
  exitGame()  if restTouch <= 0


#タッチしたボタンが正解かどうかを判断する関数
judgeAnswer = (value) ->
  if word == value
    setLevel(clickCount)
    calculateScore (clickLevel)
    if 0 == stageCount % 10
      restTouch += 15
      $('#rest #change').text('+10').css('color', 'blue').animate(opacity: 1, queue : false, 100).animate opacity: 0, 1000
    else
      restTouch += 5
      $('#rest #change').text('+5').css('color', 'blue').animate(opacity: 1, queue : false, 100).animate opacity: 0, 1000
    $('#point #score').text("""+#{bonusPoint[clickLevel]}""").css('color', 'blue').animate(opacity: 1, queue : false, 100).animate opacity: 0, 1000
    $('#point .count').text point
    $('#rest .count').text restTouch
    rebirthTime -= 5  if rebirthTime > 0
    newQuiz()
    takeScratchImage()
    time = TIME
  else
    restTouch -= 10
    $('#overlay_false').fadeIn(100).fadeOut 100
    $('#rest #change').text('-10').css('color', 'red').animate(opacity: 1, 1).animate opacity: 0, 100
    $('#rest .count').text restTouch
    if restTouch <= 0
      restTouch = 0
      $('#rest .count').text restTouch
      exitGame()  if restTouch <= 0


#新しい問題を作り出す関数
newQuiz = () ->
  stageCount++
  initQuiz()
  selectString wordArray4
  sliceString word
  takeImage sliceWordArray
  selectMatch()
  createAnswer()
  showAnswer answerArray


#初期化する関数
initQuiz = () ->
  for i in [0...scratchCount]
    $('#scratch div').eq(i).fadeIn rebirthTime
  for i in [0..5]
    $('#select div').eq(i).text ''
  for i in [0..VIEWCOUNT]
    if !$('#back_image div').eq(i).hasClass 'sprite_0'
      $('#back_image div').eq(i).removeClass().addClass 'sprite_0'
  sliceWordArray.length = 0
  numberArray.length = 0
  wordImagesArray.length = 0
  answerArray.length = 0
  clickCount = 0

#得点に関する関数
calculateScore = (value) ->
  if value == 0
    point += bonusPoint[value]
  else if value == 1
    point += bonusPoint[value]
  else if value == 2
    point += bonusPoint[value]
  else if value == 3
    point += bonusPoint[value]
  else if value == 4
    point += bonusPoint[value]
  else
    point += bonusPoint[value]


#クリック数に応じた得点のレベルを入れる関数
setLevel = (value) ->
  if 25>=value>20
    clickLevel = 0
  else if 18>=value>16
    clickLevel = 1
  else if 16>=value>14
    clickLevel = 2
  else if 14>=value>12
    clickLevel = 3
  else if 12>=value>10
    clickLevel = 4
  else if 10>=value>=8
    clickLevel = 5
  else if 8>=value>=6
    clickLevel = 6
  else if 6>=value>=4
    clickLevel = 7
  else if 4>=value>=2
    clickLevel = 8
  else if 2>=value>=0
    clickLevel = 9
  else
    clickLevel = 0


#ゲームを終了する関数
exitGame = () ->
  clearInterval timer
  $('#overlay').fadeIn 'slow'

#ゲームを初期化する関数
initScore = () ->
  time = TIME
  #残りのタッチ数
  restTouch = 50
  #消したパネルの数
  clickCount = 0
  clickLevel = 0
  #得点の初期値
  point = 0
  #現在の問題数
  stageCount = 0
  initText()

#テキストの表示を初期化する関数
initText = () ->
  $('#rest .count').text restTouch
  $('#timer .count').css('color', 'black').text time
  $('#point .count').text point

#ゲームセンターに関する処理
showLeaderboard = () ->
  GameCenter.prototype.showLeaderboard 'scratchWord_rank'

reportScore = () ->
  GameCenter.prototype.reportScore 'scratchWord_rank', newRecord
  setTimeout 'showLeaderboard()', 2000

$ ->

#画面のサイズを取得
  areaWidth = screen.width
  areaHeight = screen.height - (20 + 50 + 13) #20 : 上の白い部分 , 50 : 下の広告, 13 : 調整
  areaSize = areaWidth + areaHeight
  $('#touch_area').css 'width': '320px', 'height' : areaHeight

  addRecord()
  initText()

  $('#container_topStart').bind 'touchstart', ->
    $('#container_topStart').fadeOut 'slow'
    $('#container_start').delay(600).fadeIn 'slow'

  $('#start').bind 'touchstart', ->
    newQuiz()
    takeScratchImage()
    time = TIME
    $('#container_start').fadeOut('fast')
    $('#container_game').delay(400).fadeIn('slow')
    countStart()

  $('#ranking').bind 'touchstart', ->
    showLeaderboard()

  $('#pass div').bind 'touchstart', ->
    newQuiz()
    stageCount--

  $('#overlay #close').bind 'touchstart', ->
    $('#overlay').fadeOut 'slow'
    $('#container_game').fadeOut 'slow'
    $('#countQuestion .count').text stageCount
    $('#finalScore .count').text point
    $('#container_end').delay(400).fadeIn 'slow'
    recordStorage()

  $('#restart').bind 'touchstart', ->
    initScore()
    $('#container_end').fadeOut 'fast'
    $('#container_start').delay(400).fadeIn 'slow'
    addRecord()

  $('.scratch').bind 'touchstart', ->
    $(@).fadeOut '100'
    clickCount++
    restTouch--
    $('#rest .count').text restTouch
    $('#rest #change').text('-1').css('color', 'red').animate(opacity: 1, queue : false, 1).animate opacity: 0, 100
    exitGame()  if restTouch <= 0

  $('#select div').bind 'touchstart', ->
    touchWord = $(@).text()
    judgeAnswer touchWord
