//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【設定】

SamplerState _SamplerState {};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

inline int MinI( float A_, float B_, float C_ )
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

struct TGaussPoin
{
    float w;
    float x;
};

inline float4 GetVolume2( float3 V_, float3 P_, float T0_, float T1_ )
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
        float3 P = V_ * ( R * Gs[ I ].x + C ) + P_;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume3( float3 V_, float3 P_, float T0_, float T1_ )
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
        float3 P = V_ * ( R * Gs[ I ].x + C ) + P_;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume4( float3 V_, float3 P_, float T0_, float T1_ )
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
        float3 P = V_ * ( R * Gs[ I ].x + C ) + P_;

        _Result += Gs[ I ].w * _Texture3D.Sample( _SamplerState, P / _Size );
    }

    return R * _Result;
}

inline float4 GetVolume5( float3 V_, float3 P_, float T0_, float T1_ )
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
        float3 P = V_ * ( R * Gs[ I ].x + C ) + P_;

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

TResultP MainP( TSenderP _Sender )
{
    TResultP _Result;

    float3 P0 = _Sender.Pos.xyz;
    float3 EP = mul( _EyePos, _MatrixGL ).xyz;
    float3 EV = normalize( P0 - EP );

    int3 _VoxelsN;
    _Texture3D.GetDimensions( _VoxelsN.x,
                              _VoxelsN.y,
                              _VoxelsN.z );

    int3 Id;
    Id.x = sign( EV.x );
    Id.y = sign( EV.y );
    Id.z = sign( EV.z );

    int3 Iv[ 3 ] = { { Id.x,    0,    0 },
                     {    0, Id.y,    0 },
                     {    0,    0, Id.z } };

    float3 Sd = _Size / _VoxelsN;

    float3 Td;
    Td.x = Sd.x / abs( EV.x );
    Td.y = Sd.y / abs( EV.y );
    Td.z = Sd.z / abs( EV.z );

    float3 Tv[ 3 ] = { { Td.x,    0,    0 },
                       {    0, Td.y,    0 },
                       {    0,    0, Td.z } };

    float3 P;
    P.x = P0.x / Sd.x - 0.5;
    P.y = P0.y / Sd.y - 0.5;
    P.z = P0.z / Sd.z - 0.5;

    int3 I;
    I.x = floor( P.x );
    I.y = floor( P.y );
    I.z = floor( P.z );

    float3 Pd = P - I;

    float3 T;
    if ( EV.x > 0 ) T.x = Td.x * ( 1 - Pd.x ); else T.x = Td.x * Pd.x;
    if ( EV.y > 0 ) T.y = Td.y * ( 1 - Pd.y ); else T.y = Td.y * Pd.y;
    if ( EV.z > 0 ) T.z = Td.z * ( 1 - Pd.z ); else T.z = Td.z * Pd.z;

    _Result.Col = 0;

    float T0 = 0;

    [loop]
    while ( ( -1 <= I.x ) && ( I.x <= _VoxelsN.x )
         && ( -1 <= I.y ) && ( I.y <= _VoxelsN.y )
         && ( -1 <= I.z ) && ( I.z <= _VoxelsN.z ) )
    {
        int K = MinI( T.x, T.y, T.z );

        float T1 = T[ K ];

        _Result.Col += GetVolume2( EV, P0, T0, T1 );

        T0 = T1;

        I = I + Iv[ K ];
        T = T + Tv[ K ];
    }

    _Result.Col /= 6;

    //--------------------------------------------------------------------------

    _Result.Col.a = 0;

    _Result.Col = _Opacity * _Result.Col;

    return _Result;
}

//##############################################################################
