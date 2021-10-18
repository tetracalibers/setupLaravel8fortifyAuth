# fortifyのインストール
`composer require laravel/fortify`

# ログインフォームの日本語化
`mkdir -p ./resources/lang/ja`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/auth.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/pagination.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/passwords.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/validation.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/validation-attributes.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/validation-inline.php ./resources/lang/ja/`
`cp /Users/tomixy/Downloads/lang-master/locales/ja/ja.json ./resources/lang/`

# コンポーネントの編集を可能にする
`php artisan vendor:publish --provider="Laravel\\Fortify\\FortifyServiceProvider"`

# マイグレーションを実行
`php artisan migrate`

# config/app.phpの編集
config_app = File.open("config/app.php", "r")
buffer = config_app.read()
replaced = <<TEXT
        App\\Providers\\RouteServiceProvider::class,
        // fortifyのために追加
        App\\Providers\\FortifyServiceProvider::class,
TEXT
buffer.gsub!("        App\\Providers\\RouteServiceProvider::class,", replaced)
config_app = File.open("config/app.php", "w")
config_app.write(buffer)
config_app.close()

# app/providers/FortifyServiceProvider.phpの編集
FortifyServiceProvider_file = File.open("app/providers/FortifyServiceProvider.php", "r")
buffer = FortifyServiceProvider_file.read()
replaced = <<TEXT
        Fortify::resetUserPasswordsUsing(ResetUserPassword::class);
        // ログイン画面を表示するviewファイルを指定
        Fortify::loginView(function() { return view('auth.login'); });
        // ユーザ登録画面を表示するviewファイルを指定
        Fortify::registerView(function() { return view('auth.register'); });
TEXT
buffer.gsub!("        Fortify::resetUserPasswordsUsing(ResetUserPassword::class);", replaced)
FortifyServiceProvider_file = File.open("app/providers/FortifyServiceProvider.php", "w")
FortifyServiceProvider_file.write(buffer)
FortifyServiceProvider_file.close()

# viewファイルの作成

Dir.chdir('resources/views') do
    `mkdir auth`
end

Dir.chdir('resources/views/auth') do
# ログイン画面の雛形を作成
login_view = <<TEXT
@extends('layouts.app')
@section('title', 'ログイン')
@section('body')
<h1>ログイン画面</h1>
<x-validateErrorPrint />
<form  method="POST"　action="/login">
    @csrf
    <fieldset>
        <label for="email">メールアドレス</label>
        <input name="email" type="email" value="{{old('email')}}"/>
        <label for="password">パスワード</label>
        <input name="password" type="password" />
        <button type="submit">送信</button>
    </fieldset>
</form>
@endsection
TEXT
login_view_file = File.open("login.blade.php", "w")
login_view_file.write(login_view)
login_view_file.close()

# ユーザー登録画面の雛形を作成
register_view = <<TEXT
@extends('layouts.app')
@section('title', 'ユーザー登録')
@section('body')
<h1>ユーザー登録画面</h1>
<x-validateErrorPrint />
<form  method="POST"　action="{{ route("register") }}">
    @csrf
    <fieldset>
        <label for="name">ユーザ名</label>
        <input name="name" type="text" value="{{ old('name') }}"/>
        <label for="email">メールアドレス</label>
        <input name="email" type="email" value="{{ old('email') }}"/>
        <label for="email">パスワード</label>
        <input name="password" type="password"/>
        <label for="email">パスワード確認</label>
        <input name="password_confirmation" type="password"/>
        <button type="submit">登録</button>
    </fieldset>
</form>
@endsection
TEXT
register_view_file = File.open("register.blade.php", "w")
register_view_file.write(register_view)
register_view_file.close()
end

Dir.chdir('resources/views/components') do
# validateErrorコンポーネントの作成
validateError = <<TEXT
@if ($errors->any())
    <div>
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif
TEXT
validateError_file = File.open('validateErrorPrint.blade.php', 'w')
validateError_file.write(validateError)
validateError_file.close()

# toggleLoginコンポーネントの作成
toggleLogin = <<TEXT
@if (Route::has('login'))
    @auth
        <a href="{{ url('/home') }}">Home</a>
    @else
        <a href="{{ route('login') }}">ログイン</a>
        @if (Route::has('register'))
            <a href="{{ route('register') }}">アカウント作成</a>
        @endif
    @endauth
@endif
TEXT
toggleLogin_file = File.open('toggleLogin.blade.php', 'w')
toggleLogin_file.write(toggleLogin)
toggleLogin_file.close()
end