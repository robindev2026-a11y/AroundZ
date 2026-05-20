import SwiftUI

enum AppIcons {
    // MARK: - Navigation
    static let navAround = "antenna.radiowaves.left.and.right"
    static let navDrifts = "calendar"
    static let navChats = "bubble.left"
    static let navChatsFill = "bubble.left.fill"
    static let navYou = "person"
    static let navYouFill = "person.fill"
    
    // MARK: - General UI
    static let back = "chevron.left"
    static let arrowRight = "arrow.right"
    static let arrowLeft = "arrow.left"
    static let arrowUpRight = "arrow.up.right"
    static let chevronRight = "chevron.right"
    static let chevronDown = "chevron.down"
    static let plus = "plus"
    static let checkmark = "checkmark"
    static let checkCircleFill = "checkmark.circle.fill"
    static let verified = "checkmark.seal.fill"
    static let close = "xmark"
    static let ellipsis = "ellipsis"
    static let more = "ellipsis"
    static let infoCircle = "info.circle"
    static let paperclip = "paperclip"
    static let paperplaneFill = "paperplane.fill"
    static let refresh = "arrow.clockwise"
    
    // MARK: - Features & Actions
    static let search = "magnifyingglass"
    static let filter = "slider.horizontal.3"
    static let share = "square.and.arrow.up"
    static let bookmark = "bookmark"
    static let bookmarkFill = "bookmark.fill"
    static let bell = "bell"
    static let bellFill = "bell.fill"
    static let sparkles = "sparkles"
    static let gift = "gift.fill"
    static let helpTip = "lightbulb"
    static let briefcase = "briefcase"
    static let notes = "note.text"
    
    // MARK: - Discovery & Activity
    static let coffee = "cup.and.saucer"
    static let coffeeFill = "cup.and.saucer.fill"
    static let walk = "figure.walk"
    static let movie = "film"
    static let food = "fork.knife"
    static let study = "book"
    static let chatGroup = "bubble.left.and.bubble.right.fill"
    static let fitness = "bolt.fill"
    static let games = "gamecontroller.fill"
    static let music = "music.note"
    static let sports = "sportscourt"
    static let drinks = "wineglass"
    static let custom = "sparkles"
    static let moon = "moon.fill"
    
    // MARK: - Spatial & Info
    static let calendar = "calendar"
    static let clock = "clock"
    static let clockFill = "clock.fill"
    static let location = "location.fill"
    static let map = "map.fill"
    static let mappin = "mappin.and.ellipse"
    static let participants = "person.2.fill"
    static let person = "person.fill"
    static let distance = "figure.walk.circle"
    
    // MARK: - Security
    static let shield = "shield.fill"
    static let shieldVerified = "checkmark.shield.fill"
    static let privacyShield = "checkmark.shield"
    static let lock = "lock.fill"
    static let bolt = "bolt.fill"
    static let heart = "heart"
    static let heartFill = "heart.fill"
    
    // MARK: - Media
    static let camera = "camera.fill"
    static let cameraOutline = "camera"
    static let photo = "photo.on.rectangle.angled"
    
    // MARK: - Settings & Profile
    static let settings = "gearshape"
    static let logout = "arrow.right.square"
    static let logoutFill = "arrow.right.square.fill"
    static let block = "nosign"
    static let report = "exclamationmark.shield"
    static let visibility = "eye"
    static let account = "person.badge.key"
    static let privacy = "hand.raised.fill"
    static let edit = "pencil"
    static let mappinCircle = "mappin.circle.fill"
    static let help = "questionmark.circle.fill"
    
    // MARK: - SwiftUI Image Accessors
    static var navAroundImage: Image { Image(systemName: navAround) }
    static var navDriftsImage: Image { Image(systemName: navDrifts) }
    static var navChatsImage: Image { Image(systemName: navChats) }
    static var navChatsFillImage: Image { Image(systemName: navChatsFill) }
    static var navYouImage: Image { Image(systemName: navYou) }
    static var navYouFillImage: Image { Image(systemName: navYouFill) }
    
    static var backImage: Image { Image(systemName: back) }
    static var arrowRightImage: Image { Image(systemName: arrowRight) }
    static var arrowLeftImage: Image { Image(systemName: arrowLeft) }
    static var arrowUpRightImage: Image { Image(systemName: arrowUpRight) }
    static var chevronRightImage: Image { Image(systemName: chevronRight) }
    static var chevronDownImage: Image { Image(systemName: chevronDown) }
    static var plusImage: Image { Image(systemName: plus) }
    static var checkmarkImage: Image { Image(systemName: checkmark) }
    static var checkCircleFillImage: Image { Image(systemName: checkCircleFill) }
    static var verifiedImage: Image { Image(systemName: verified) }
    static var closeImage: Image { Image(systemName: close) }
    static var ellipsisImage: Image { Image(systemName: ellipsis) }
    static var infoCircleImage: Image { Image(systemName: infoCircle) }
    static var paperclipImage: Image { Image(systemName: paperclip) }
    static var paperplaneFillImage: Image { Image(systemName: paperplaneFill) }
    static var refreshImage: Image { Image(systemName: refresh) }
    
    static var searchImage: Image { Image(systemName: search) }
    static var filterImage: Image { Image(systemName: filter) }
    static var shareImage: Image { Image(systemName: share) }
    static var bookmarkImage: Image { Image(systemName: bookmark) }
    static var bookmarkFillImage: Image { Image(systemName: bookmarkFill) }
    static var bellImage: Image { Image(systemName: bell) }
    static var bellFillImage: Image { Image(systemName: bellFill) }
    
    static var coffeeImage: Image { Image(systemName: coffee) }
    static var coffeeFillImage: Image { Image(systemName: coffeeFill) }
    static var walkImage: Image { Image(systemName: walk) }
    static var movieImage: Image { Image(systemName: movie) }
    static var foodImage: Image { Image(systemName: food) }
    static var studyImage: Image { Image(systemName: study) }
    
    static var clockImage: Image { Image(systemName: clock) }
    static var clockFillImage: Image { Image(systemName: clockFill) }
    static var locationImage: Image { Image(systemName: location) }
    static var mapImage: Image { Image(systemName: map) }
    static var mappinImage: Image { Image(systemName: mappin) }
    static var participantsImage: Image { Image(systemName: participants) }
    static var personImage: Image { Image(systemName: person) }
    
    static var lockImage: Image { Image(systemName: lock) }
    static var blockImage: Image { Image(systemName: block) }
    static var reportImage: Image { Image(systemName: report) }
    
    // Remaining accessors
    static var calendarImage: Image { Image(systemName: calendar) }
    static var cameraImage: Image { Image(systemName: camera) }
    static var cameraOutlineImage: Image { Image(systemName: cameraOutline) }
    static var photoImage: Image { Image(systemName: photo) }
    static var sparklesImage: Image { Image(systemName: sparkles) }
    static var giftImage: Image { Image(systemName: gift) }
    static var helpTipImage: Image { Image(systemName: helpTip) }
    static var briefcaseImage: Image { Image(systemName: briefcase) }
    static var notesImage: Image { Image(systemName: notes) }
    static var chatGroupImage: Image { Image(systemName: chatGroup) }
    static var fitnessImage: Image { Image(systemName: fitness) }
    static var gamesImage: Image { Image(systemName: games) }
    static var musicImage: Image { Image(systemName: music) }
    static var sportsImage: Image { Image(systemName: sports) }
    static var drinksImage: Image { Image(systemName: drinks) }
    static var customImage: Image { Image(systemName: custom) }
    static var moonImage: Image { Image(systemName: moon) }
    static var distanceImage: Image { Image(systemName: distance) }
    static var shieldImage: Image { Image(systemName: shield) }
    static var shieldVerifiedImage: Image { Image(systemName: shieldVerified) }
    static var privacyShieldImage: Image { Image(systemName: privacyShield) }
    static var boltImage: Image { Image(systemName: bolt) }
    static var heartImage: Image { Image(systemName: heart) }
    static var heartFillImage: Image { Image(systemName: heartFill) }
    static var settingsImage: Image { Image(systemName: settings) }
    static var logoutImage: Image { Image(systemName: logout) }
    static var logoutFillImage: Image { Image(systemName: logoutFill) }
    static var visibilityImage: Image { Image(systemName: visibility) }
    static var accountImage: Image { Image(systemName: account) }
    static var privacyImage: Image { Image(systemName: privacy) }
    static var editImage: Image { Image(systemName: edit) }
    static var mappinCircleImage: Image { Image(systemName: mappinCircle) }
    static var helpImage: Image { Image(systemName: help) }
}
