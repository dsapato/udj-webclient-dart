part of udjlib;

// SideBarView
// ============================================================================

class SideBarView extends CompositeView {
  final UdjApp _udjApp;
  
  final SideBarState _state;
  
  View _playerInfo;  
  AdminPlayerView _controls;
  AdminUserView _users;
  View _nowPlaying;
  QueueView _queueView;
  
  // Constructors
  // --------------------------------------------------------------------------
  
  SideBarView(this._udjApp,this._state):super('sidebar-box'){
    // TODO: show player volume
    _playerInfo = new View.html('''
      <div class="player">
        <div class="player-current">
          <span class="player-name"></span>
          <button id="player-change" class="player-change btn"><i class="icon-caret-down"></i></button>
        </div>
        <div class="player-user-count"><i class="icon-user"></i></div>
        <div class="player-queue-count"><i class="icon-music"></i></div>
      </div>
    ''');
    addChild(_playerInfo);
    
    // admin
    
    AdminPlayerState controlsState = new AdminPlayerState(_udjApp);
    _controls = new AdminPlayerView(_udjApp, controlsState);
    
    AdminUserState usersState = new AdminUserState(_udjApp);
    _users = new AdminUserView(_udjApp, usersState);
    
    if (_udjApp.state.canAdmin()) {
      addChild(_controls);
      addChild(_users);
    }
    
    _nowPlaying = new View.html('''
      <div class="now-playing-box">
        <div class="now-playing-status"><i class="icon-pause"></i></div>
        <div class="now-playing-song-title"></div>
        <span class="now-playing-song-artist"></span><span class="now-playing-song-album"></span>
      </div>
    ''');
    addChild(_nowPlaying);
    
    _queueView = new QueueView(_udjApp,_state);
    addChild(_queueView);
  }
  
  void afterRender(Element node){
    // player info watching
    watch(_udjApp.state.currentPlayer, _changeCurrentPlayer);
    watch(_udjApp.state.queue,(e) => _queueView.rerender());
    watch(_udjApp.state.queue,_updateQueueCount);
    watch(_udjApp.state.nowPlaying,_changeNowPlaying);
    watch(_udjApp.state.playerState,_changePlayerState);
    
    // events
    _playerInfo.node.query("#player-change").on.click.add((Event e) {
      _udjApp.state.currentPlayer.value = null;
    });
  }
  
  // Watchers
  // --------------------------------------------------------------------------
  
  /**
   * Update the player the user is currently in.
   */
  void _changeCurrentPlayer(e) {
    Player p = _udjApp.state.currentPlayer.value;
    if (p != null) {
      _playerInfo.node.query(".player-name").text = p.name;
      _playerInfo.node.query(".player-user-count").innerHtml = '<i class="icon-user"></i> ${p.numActiveUsers}';
      _updateQueueCount(null);
      
    } else {
      _playerInfo.node.query(".player-name").text = "";
      _playerInfo.node.query(".player-user-count").text = "";
      _playerInfo.node.query(".player-queue-count").text = "";
      
    }
  }
  
  /**
   * Updates the number of songs in the queue.
   */
  void _updateQueueCount(e) {
    List<QueueSong> queue = _udjApp.state.queue.value;
    if (queue != null && _udjApp.state.currentPlayer.value != null) {
      _playerInfo.node.query(".player-queue-count").innerHtml = '<i class="icon-music"></i> ${queue.length}';
      
    } else {
      _playerInfo.node.query(".player-queue-count").innerHtml = '<i class="icon-music"></i> --';
      
    }
  }
  
  void _changeNowPlaying(e){
    if(_udjApp.state.nowPlaying.value != null){
      _nowPlaying.node.query(".now-playing-song-title").text = _udjApp.state.nowPlaying.value.title;
      _nowPlaying.node.query(".now-playing-song-artist").text = _udjApp.state.nowPlaying.value.artist;
      _nowPlaying.node.query(".now-playing-song-album").text = _udjApp.state.nowPlaying.value.album;
    }
  }
  
  void _changePlayerState(e){
    // TODO: refactor to a constant
    if(_udjApp.state.playerState == "Playing"){
      _nowPlaying.node.query(".now-playing-status").innerHtml = '<i class="icon-play"></i>';
    }else{
      _nowPlaying.node.query(".now-playing-status").innerHtml = '<i class="icon-pause"></i>';
    }
  }
  
}


// LoginView
// ============================================================================

class QueueView extends CompositeView{
  final UdjApp _udjApp;
  
  final SideBarState _state;
  
  // Constructors
  // --------------------------------------------------------------------------
  
  QueueView(this._udjApp,this._state):super('queue-box',true,true,true,true){
    rerender();
  }
  
  void rerender(){
    removeAllChildren();
    if(_udjApp.state.queue.value != null){
      for(var s in _udjApp.state.queue.value){
        View song = new SongView(_udjApp,s);
        addChild(song);
      }
    }
    
  }
}
