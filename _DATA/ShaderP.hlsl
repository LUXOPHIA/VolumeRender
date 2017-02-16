//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

struct TRay
{
    float3 Pos;
    float3 Vec;
};

inline TRay newTRay( const float3 Pos_, const float3 Vec_ )
{
    TRay Result;

    Result.Pos = Pos_;
    Result.Vec = Vec_;

    return Result;
}

//------------------------------------------------------------------------------

struct TGaussPoin
{
    float w;
    float x;
};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【設定】

SamplerState _SamplerState {};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

inline int3 sign3( const float3 P_ )
{
    int3 Result;

    Result.x = sign( P_.x );
    Result.y = sign( P_.y );
    Result.z = sign( P_.z );

    return Result;
}

inline float3 abs3( const float3 P_ )
{
    float3 Result;

    Result.x = abs( P_.x );
    Result.y = abs( P_.y );
    Result.z = abs( P_.z );

    return Result;
}

inline int3 floor3( const float3 P_ )
{
    int3 Result;

    Result.x = floor( P_.x );
    Result.y = floor( P_.y );
    Result.z = floor( P_.z );

    return Result;
}

inline int MinI( const float A_, const float B_, const float C_ )
{
    if ( A_ <= B_ )
    {
        if ( A_ <= C_ ) return 0;
                   else return 2;
    }
    else
    {
        if ( B_ <= C_ ) return 1;
                   else return 2;
    }
}

////////////////////////////////////////////////////////////////////////////////

inline float4 GetVolume2( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 1 ] = { { 1.0, sqrt( 1.0 / 3.0 ) } };

    const TGaussPoin Gs[ 2 ] = { { G[ 0 ].w, -G[ 0 ].x },
                                 { G[ 0 ].w, +G[ 0 ].x } };

    float4 _Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 2; I++ )
    {
        float3 P = R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume3( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 2 ] = { { 8.0 / 9.0, 0.0               },
                                { 5.0 / 9.0, sqrt( 3.0 / 5.0 ) } };

    const TGaussPoin Gs[ 3 ] = { { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w,  G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x } };

    float4 _Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 3; I++ )
    {
        float3 P = R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume4( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 2 ] = { { ( 18.0 + sqrt( 30.0 ) ) / 36.0, sqrt( ( 3.0 - 2.0 * sqrt( 6.0 / 5.0 ) ) / 7.0 ) },
                                { ( 18.0 - sqrt( 30.0 ) ) / 36.0, sqrt( ( 3.0 + 2.0 * sqrt( 6.0 / 5.0 ) ) / 7.0 ) } };

    const TGaussPoin Gs[ 4 ] = { { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w, -G[ 0 ].x },
                                 { G[ 0 ].w, +G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x } };

    float4 _Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 4; I++ )
    {
        float3 P = R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume5( const TRay R_, const float T0_, const float T1_ )
{
    const TGaussPoin G[ 3 ] = { {   128.0                         / 225.0, 0.0                                          },
                                { ( 322.0 + 13.0 * sqrt( 70.0 ) ) / 900.0, sqrt( 5.0 - 2.0 * sqrt( 10.0 / 7.0 ) ) / 3.0 },
                                { ( 322.0 - 13.0 * sqrt( 70.0 ) ) / 900.0, sqrt( 5.0 + 2.0 * sqrt( 10.0 / 7.0 ) ) / 3.0 } };

    const TGaussPoin Gs[ 5 ] = { { G[ 2 ].w, -G[ 2 ].x },
                                 { G[ 1 ].w, -G[ 1 ].x },
                                 { G[ 0 ].w,  G[ 0 ].x },
                                 { G[ 1 ].w, +G[ 1 ].x },
                                 { G[ 2 ].w, +G[ 2 ].x } };

    float4 _Result = 0;

    float C = ( T1_ + T0_ ) / 2;
    float R = ( T1_ - T0_ ) / 2;

    [unroll]
    for ( uint I = 0; I < 5; I++ )
    {
        float3 P = R_.Vec * ( R * Gs[ I ].x + C ) + R_.Pos;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

//##############################################################################

struct TSenderP
{
    float4 Scr :SV_Position;
    float4 Pos :TEXCOORD0  ;
};

struct TResultP
{
    float4 Col :SV_Target;
};

////////////////////////////////////////////////////////////////////////////////

TResultP MainP( const TSenderP _Sender )
{
    TResultP Result;

    float3 E = mul( _EyePos, _MatrixGL ).xyz;

    TRay R = newTRay( _Sender.Pos.xyz, normalize( _Sender.Pos.xyz - E ) );

    int3 _VoxelsN;
    _Texture3D.GetDimensions( _VoxelsN.x, _VoxelsN.y, _VoxelsN.z );

    int3 Id = sign3( R.Vec );

    int3 Iv[ 3 ] = { { Id.x,    0,    0 },
                     {    0, Id.y,    0 },
                     {    0,    0, Id.z } };

    float3 Sd = _Size / _VoxelsN;

    float3 Td = Sd / abs3( R.Vec );

    float3 Tv[ 3 ] = { { Td.x,    0,    0 },
                       {    0, Td.y,    0 },
                       {    0,    0, Td.z } };

    float3 P = R.Pos / Sd - float3( 0.5, 0.5, 0.5 );

    int3 I = floor3( P );

    float3 Pd = P - I;

    float3 T;
    if ( R.Vec.x > 0 ) T.x = Td.x * ( 1 - Pd.x ); else T.x = Td.x * Pd.x;
    if ( R.Vec.y > 0 ) T.y = Td.y * ( 1 - Pd.y ); else T.y = Td.y * Pd.y;
    if ( R.Vec.z > 0 ) T.z = Td.z * ( 1 - Pd.z ); else T.z = Td.z * Pd.z;

    Result.Col = 0;

    float T0 = 0;

    [loop]
    while ( ( -1 <= I.x ) && ( I.x <= _VoxelsN.x )
         && ( -1 <= I.y ) && ( I.y <= _VoxelsN.y )
         && ( -1 <= I.z ) && ( I.z <= _VoxelsN.z ) )
    {
        int K = MinI( T.x, T.y, T.z );

        float T1 = T[ K ];

        Result.Col += GetVolume2( R, T0, T1 );

        T0 = T1;

        I = I + Iv[ K ];
        T = T + Tv[ K ];
    }

    Result.Col /= 6;

    //--------------------------------------------------------------------------

    Result.Col.a = 0;

    Result.Col = _Opacity * Result.Col;

    return Result;
}

//##############################################################################
